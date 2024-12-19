require 'rails_helper'

RSpec.describe 'Messages API', type: :request do
  let(:admin_user) { create(:user, role: :admin) }
  let(:regular_user) { create(:user, role: :regular) }
  let(:other_user) { create(:user, role: :regular) }

  let!(:ticket) { create(:ticket, user: regular_user) }
  let!(:other_ticket) { create(:ticket, user: other_user) }

  let!(:message) { create(:message, content: 'First message', user: regular_user, ticket: ticket) }
  let!(:other_message) { create(:message, content: 'Other message', user: other_user, ticket: ticket) }

  let(:valid_attributes) { { content: 'New message content' } }
  let(:invalid_attributes) { { content: '' } }

  describe 'GET /tickets/:ticket_id/messages' do
    context 'when the user is authorized' do
      it 'returns all messages for the ticket' do
        headers = authenticate_user(regular_user)
        get ticket_messages_path(ticket), headers: headers
      
        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(2) # Two messages exist for the ticket
        expect(json.first['content']).to eq('Other message') # Last created message
        expect(json.last['content']).to eq('First message') # First created message
            end
    end
  end

  describe 'POST /tickets/:ticket_id/messages' do
    context 'with invalid attributes' do
      it 'does not create a new message' do
        headers = authenticate_user(regular_user)
        expect {
          post ticket_messages_path(ticket), params: { message: invalid_attributes }, headers: headers
        }.not_to change(Message, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['content']).to include("can't be blank")
      end
    end
  end

  describe 'DELETE /tickets/:ticket_id/messages/:id' do
    context 'when the user is authorized' do
      it 'deletes the message' do
        headers = authenticate_user(regular_user)
        expect {
          delete ticket_message_path(ticket, message), headers: headers
        }.to change(Message, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Deleted.')
      end
    end

    context 'when the user is not authorized' do
      it 'returns a forbidden error' do
        headers = authenticate_user(other_user)
        expect {
          delete ticket_message_path(ticket, message), headers: headers
        }.not_to change(Message, :count)

        expect(response).to have_http_status(:forbidden)
        expect(json['error']).to eq('You are not authorized to access this item.')
      end
    end
  end

  # Helper for parsing JSON responses
  def json
    JSON.parse(response.body)
  end
end