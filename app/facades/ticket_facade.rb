class TicketFacade
    def self.create_ticket(params, user)
      Ticket.create(name: params[:name], description: params[:description], user: user)
    end
  end