require 'rails_helper'

RSpec.describe 'Tickets API', type: :request do
  let(:admin_user) { create(:user, role: :admin) }
  let(:regular_user) { create(:user, role: :regular) }
  let(:other_user) { create(:user, role: :regular) }
  let!(:admin_ticket) { create(:ticket, user: admin_user) }
  let!(:user_ticket) { create(:ticket, user: regular_user) }
  let!(:other_user_ticket) { create(:ticket, user: other_user) }

  let(:valid_attributes) { { name: 'New Ticket', description: 'A sample ticket.', sentiment: 5 } }
  let(:invalid_attributes) { { name: '', description: '', sentiment: nil } }

  describe 'GET /tickets' do
    context 'when the user is an admin' do
      it 'returns all tickets' do
        headers = authenticate_user(admin_user)
        get tickets_path, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(3) # Admin can see all tickets
        expect(json.first['user']).to have_key('email') # Includes user details
      end
    end

    context 'when the user is regular' do
      it 'returns only the tickets they own' do
        headers = authenticate_user(regular_user)
        get tickets_path, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(1) # Regular user can only see their own tickets
        expect(json.first['id']).to eq(user_ticket.id)
      end
    end
  end

  describe 'POST /tickets' do
    context 'with valid attributes' do
      it 'creates a new ticket' do
        headers = authenticate_user(regular_user)
        expect {
          post tickets_path, params: { ticket: valid_attributes }, headers: headers
        }.to change(Ticket, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json['name']).to eq(valid_attributes[:name])
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new ticket' do
        headers = authenticate_user(regular_user)
        expect {
          post tickets_path, params: { ticket: invalid_attributes }, headers: headers
        }.not_to change(Ticket, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['name']).to include("can't be blank")
      end
    end
  end

  describe 'GET /tickets/:id' do
    context 'when the user is authorized' do
      it 'returns the ticket' do
        headers = authenticate_user(regular_user)
        get ticket_path(user_ticket), headers: headers

        expect(response).to have_http_status(:ok)
        expect(json['id']).to eq(user_ticket.id)
      end
    end

    context 'when the user is not authorized' do
      it 'returns a forbidden error' do
        headers = authenticate_user(regular_user)
        get ticket_path(other_user_ticket), headers: headers

        expect(response).to have_http_status(:forbidden)
        expect(json['error']).to eq('You are not authorized to access this item.')
      end
    end
  end

  describe 'PUT /tickets/:id' do
    context 'when the user is authorized' do
      it 'updates the ticket' do
        headers = authenticate_user(regular_user)
        put ticket_path(user_ticket), params: { ticket: { name: 'Updated Ticket' } }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json['name']).to eq('Updated Ticket')
      end
    end

    context 'when the user is not authorized' do
      it 'returns a forbidden error' do
        headers = authenticate_user(regular_user)
        put ticket_path(other_user_ticket), params: { ticket: { name: 'Updated Ticket' } }, headers: headers

        expect(response).to have_http_status(:forbidden)
        expect(json['error']).to eq('You are not authorized to access this item.')
      end
    end

    context 'with invalid attributes' do
      it 'does not update the ticket' do
        headers = authenticate_user(regular_user)
        put ticket_path(user_ticket), params: { ticket: { name: '' } }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json['name']).to include("can't be blank")
      end
    end
  end

  describe 'DELETE /tickets/:id' do
    context 'when the user is authorized' do
      it 'deletes the ticket' do
        headers = authenticate_user(regular_user)
        expect {
          delete ticket_path(user_ticket), headers: headers
        }.to change(Ticket, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json['message']).to eq('Deleted.')
      end
    end

    context 'when the user is not authorized' do
      it 'returns a forbidden error' do
        headers = authenticate_user(regular_user)
        expect {
          delete ticket_path(other_user_ticket), headers: headers
        }.not_to change(Ticket, :count)

        expect(response).to have_http_status(:forbidden)
        expect(json['error']).to eq('You are not authorized to access this item.')
      end
    end
  end

  # Helper for parsing JSON responses
  # def json
  #   JSON.parse(response.body)
  # end
end