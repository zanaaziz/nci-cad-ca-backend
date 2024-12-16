class TicketsController < ApplicationController
  before_action :authenticate_user! # Require login
  before_action :set_ticket, only: %i[show update destroy]
  before_action :authorize_admin!, only: %i[index]

  # GET /tickets (Admin only)
  def index
    @tickets = Ticket.all
    render json: @tickets
  end

  # POST /tickets (Regular users create tickets)
  def create
    @ticket = TicketFacade.create_ticket(ticket_params, current_user)

    if @ticket.persisted?
      render json: @ticket, status: :created
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
  end

  # PUT /tickets/:id (Update ticket)
  def update
    authorize_owner!

    if @ticket.update(ticket_params)
      render json: @ticket
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tickets/:id (Delete ticket)
  def destroy
    authorize_owner!
    @ticket.destroy
    head :no_content
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:name, :description)
  end

  def authorize_owner!
    head :forbidden unless @ticket.user == current_user
  end

  def authorize_admin!
    head :forbidden unless current_user.admin?
  end
end