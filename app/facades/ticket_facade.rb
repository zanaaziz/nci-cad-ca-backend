# Facade to handle ticket creation logic
class TicketFacade
  # Creates a new ticket with the given parameters and user
  #
  # @param params [Hash] Parameters for the ticket (e.g., name, description)
  # @param user [User] The user creating the ticket
  # @return [Ticket] The created Ticket object
  def self.create_ticket(params, user)
    Ticket.create(
      name: params[:name],       # Ticket name from the parameters
      description: params[:description], # Ticket description from the parameters
      user: user                 # Associate the ticket with the user
    )
  end
end