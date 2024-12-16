class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket, only: %i[show update destroy]
  before_action :authorize_access!, except: [:index, :create]

  # GET /tickets
  # Admins can view all tickets, while regular users can only view their own.
  def index
    if current_user.admin?
      @tickets = Ticket.includes(:user).all

      render json: @tickets.as_json(
        except: [:user_id], # Exclude user_id from the response
        include: { user: { only: [:id, :email, :role] } } # Include limited user details
      ), status: :ok
    else
      @tickets = current_user.tickets
      render json: @tickets, status: :ok
    end
  end

  # POST /tickets
  # Creates a new ticket using the TicketFacade.
  def create
    @ticket = TicketFacade.create_ticket(ticket_params, current_user)

    if @ticket.persisted?
      render json: @ticket, status: :created
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
  end

  # GET /tickets/:id
  # Returns details of a specific ticket.
  def show
    render json: @ticket, status: :ok
  end

  # PUT /tickets/:id
  # Updates the details of an existing ticket.
  def update
    if @ticket.update(ticket_params)
      render json: @ticket
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tickets/:id
  # Deletes a specific ticket.
  def destroy
    @ticket.destroy
    render json: { message: 'Deleted.' }, status: :ok
  end

  private

  # Finds a ticket by ID.
  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  # Strong parameters for ticket creation and updates.
  def ticket_params
    params.require(:ticket).permit(:name, :description, :sentiment)
  end

  # Authorizes access to tickets for regular users (only their own).
  def authorize_access!
    if !current_user.admin? && @ticket.user != current_user
      render json: { error: 'You are not authorized to access this item.' }, status: :forbidden
    end
  end
end