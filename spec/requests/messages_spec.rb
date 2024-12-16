require 'rails_helper'

# Test suite for the Messages API
RSpec.describe 'Messages API', type: :request do
  # Define users with different roles
  let(:admin_user) { create(:user, role: :admin) }
  let(:regular_user) { create(:user, role: :regular) }
  let(:other_user) { create(:user, role: :regular) }

  # Define tickets and their associations
  let!(:ticket) { create(:ticket, user: regular_user) }
  let!(:other_ticket) { create(:ticket, user: other_user) }

  # Define messages and associate them with users and tickets
  let!(:message) { create(:message, content: 'First message', user: regular_user, ticket: ticket) }
  let!(:other_message) { create(:message, content: 'Other message', user: other_user, ticket: ticket) }

  # Define valid and invalid attributes for message creation
  let(:valid_attributes) { { content: 'New message content' } }
  let(:invalid_attributes) { { content: '' } }

  # Tests for retrieving messages for a ticket
  describe 'GET /tickets/:ticket_id/messages' do
    context 'when the user is authorized' do
      it 'returns all messages for the ticket' do
        headers = authenticate_user(regular_user) # Authenticate the user
        get ticket_messages_path(ticket), headers: headers # Make the GET request

        expect(response).to have_http_status(:ok) # Check if response status is 200 (OK)
        expect(json.size).to eq(2) # Verify the number of messages returned
        expect(json.first['content']).to eq('First message') # Check the content of the first message
        expect(json.last['content']).to eq('Other message') # Check the content of the second message
      end
    end
  end

  # Tests for creating a new message
  describe 'POST /tickets/:ticket_id/messages' do
    context 'with invalid attributes' do
      it 'does not create a new message' do
        headers = authenticate_user(regular_user) # Authenticate the user
        expect {
          post ticket_messages_path(ticket), params: { message: invalid_attributes }, headers: headers
        }.not_to change(Message, :count) # Ensure no message is created

        expect(response).to have_http_status(:unprocessable_entity) # Check for validation error status
        expect(json['content']).to include("can't be blank") # Validate the error message
      end
    end
  end

  # Tests for deleting a message
  describe 'DELETE /tickets/:ticket_id/messages/:id' do
    context 'when the user is authorized' do
      it 'deletes the message' do
        headers = authenticate_user(regular_user) # Authenticate the user
        expect {
          delete ticket_message_path(ticket, message), headers: headers
        }.to change(Message, :count).by(-1) # Ensure the message count decreases by 1

        expect(response).to have_http_status(:ok) # Check for successful deletion
        expect(json['message']).to eq('Deleted.') # Validate the deletion response message
      end
    end

    context 'when the user is not authorized' do
      it 'returns a forbidden error' do
        headers = authenticate_user(other_user) # Authenticate a different user
        expect {
          delete ticket_message_path(ticket, message), headers: headers
        }.not_to change(Message, :count) # Ensure the message is not deleted

        expect(response).to have_http_status(:forbidden) # Check for forbidden status
        expect(json['error']).to eq('You are not authorized to access this item.') # Validate the error message
      end
    end
  end
end