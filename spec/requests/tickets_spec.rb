require 'rails_helper'

# Test suite for the Tickets API
RSpec.describe 'Tickets API', type: :request do
  # Define different users with roles for testing authorization
  let(:admin_user) { create(:user, role: :admin) }
  let(:regular_user) { create(:user, role: :regular) }
  let(:other_user) { create(:user, role: :regular) }

  # Tickets created by different users
  let!(:admin_ticket) { create(:ticket, user: admin_user) }
  let!(:user_ticket) { create(:ticket, user: regular_user) }
  let!(:other_user_ticket) { create(:ticket, user: other_user) }

  # Valid and invalid attributes for testing ticket creation and updates
  let(:valid_attributes) { { name: 'New Ticket', description: 'A sample ticket.', sentiment: 5 } }
  let(:invalid_attributes) { { name: '', description: '', sentiment: nil } }

  # Test for GET /tickets
  describe 'GET /tickets' do
    context 'when the user is an admin' do
      it 'returns all tickets' do
        headers = authenticate_user(admin_user) # Simulate admin authentication
        get tickets_path, headers: headers # Send GET request to fetch all tickets

        expect(response).to have_http_status(:ok) # Expect HTTP 200 status
        expect(json.size).to eq(3) # Check the number of tickets returned
        expect(json.first['user']).to have_key('email') # Verify included user details
      end
    end

    context 'when the user is regular' do
      it 'returns only the tickets they own' do
        headers = authenticate_user(regular_user) # Simulate regular user authentication
        get tickets_path, headers: headers # Send GET request

        expect(response).to have_http_status(:ok) # Expect HTTP 200 status
        expect(json.size).to eq(1) # Only their tickets should be returned
        expect(json.first['id']).to eq(user_ticket.id) # Verify correct ticket is returned
      end
    end
  end

  # Test for POST /tickets
  describe 'POST /tickets' do
    context 'with valid attributes' do
      it 'creates a new ticket' do
        headers = authenticate_user(regular_user) # Simulate user authentication
        expect {
          post tickets_path, params: { ticket: valid_attributes }, headers: headers
        }.to change(Ticket, :count).by(1) # Check if ticket count increases

        expect(response).to have_http_status(:created) # Expect HTTP 201 status
        expect(json['name']).to eq(valid_attributes[:name]) # Verify ticket name
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new ticket' do
        headers = authenticate_user(regular_user)
        expect {
          post tickets_path, params: { ticket: invalid_attributes }, headers: headers
        }.not_to change(Ticket, :count) # Ensure no new ticket is created

        expect(response).to have_http_status(:unprocessable_entity) # Expect validation error status
        expect(json['name']).to include("can't be blank") # Verify error message
      end
    end
  end

  # Test for GET /tickets/:id
  describe 'GET /tickets/:id' do
    context 'when the user is authorized' do
      it 'returns the ticket' do
        headers = authenticate_user(regular_user)
        get ticket_path(user_ticket), headers: headers

        expect(response).to have_http_status(:ok) # Expect HTTP 200 status
        expect(json['id']).to eq(user_ticket.id) # Verify returned ticket
      end
    end

    context 'when the user is not authorized' do
      it 'returns a forbidden error' do
        headers = authenticate_user(regular_user)
        get ticket_path(other_user_ticket), headers: headers

        expect(response).to have_http_status(:forbidden) # Expect HTTP 403 status
        expect(json['error']).to eq('You are not authorized to access this item.') # Verify error message
      end
    end
  end

  # Test for PUT /tickets/:id
  describe 'PUT /tickets/:id' do
    context 'when the user is authorized' do
      it 'updates the ticket' do
        headers = authenticate_user(regular_user)
        put ticket_path(user_ticket), params: { ticket: { name: 'Updated Ticket' } }, headers: headers

        expect(response).to have_http_status(:ok) # Expect HTTP 200 status
        expect(json['name']).to eq('Updated Ticket') # Verify updated ticket name
      end
    end

    context 'when the user is not authorized' do
      it 'returns a forbidden error' do
        headers = authenticate_user(regular_user)
        put ticket_path(other_user_ticket), params: { ticket: { name: 'Updated Ticket' } }, headers: headers

        expect(response).to have_http_status(:forbidden) # Expect HTTP 403 status
        expect(json['error']).to eq('You are not authorized to access this item.') # Verify error message
      end
    end

    context 'with invalid attributes' do
      it 'does not update the ticket' do
        headers = authenticate_user(regular_user)
        put ticket_path(user_ticket), params: { ticket: { name: '' } }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity) # Expect validation error status
        expect(json['name']).to include("can't be blank") # Verify error message
      end
    end
  end

  # Test for DELETE /tickets/:id
  describe 'DELETE /tickets/:id' do
    context 'when the user is authorized' do
      it 'deletes the ticket' do
        headers = authenticate_user(regular_user)
        expect {
          delete ticket_path(user_ticket), headers: headers
        }.to change(Ticket, :count).by(-1) # Ensure ticket count decreases

        expect(response).to have_http_status(:ok) # Expect HTTP 200 status
        expect(json['message']).to eq('Deleted.') # Verify deletion message
      end
    end

    context 'when the user is not authorized' do
      it 'returns a forbidden error' do
        headers = authenticate_user(regular_user)
        expect {
          delete ticket_path(other_user_ticket), headers: headers
        }.not_to change(Ticket, :count) # Ensure no ticket is deleted

        expect(response).to have_http_status(:forbidden) # Expect HTTP 403 status
        expect(json['error']).to eq('You are not authorized to access this item.') # Verify error message
      end
    end
  end
end