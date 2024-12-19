class TicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket, only: %i[show update destroy]
  before_action :authorize_access!, except: [:index, :create]

  # GET /tickets
  def index
    if current_user.admin?
      # Admin users can see all tickets
      @tickets = Ticket.includes(:user).all.order(created_at: :desc)

      render json: @tickets.as_json(
        except: [:user_id],
        include: { user: { only: [:id, :email, :role] } }
      ), status: :ok
    else
      # Regular users can see only their own tickets
      @tickets = current_user.tickets
      render json: @tickets, status: :ok
    end
  end

  # POST /tickets
  def create
    @ticket = TicketFacade.create_ticket(ticket_params, current_user)

    if @ticket.persisted?
      render json: @ticket, status: :created
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
  end

  # GET /tickets/:id
  def show
    render json: @ticket, status: :ok
  end

  # PUT /tickets/:id
  def update
    if @ticket.update(ticket_params)
      render json: @ticket
    else
      render json: @ticket.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tickets/:id
  def destroy
    @ticket.destroy
    render json: { message: 'Deleted.' }, status: :ok
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:name, :description, :sentiment)
  end

  def authorize_access!
    if !current_user.admin? && @ticket.user != current_user
      return render json: { error: 'You are not authorized to access this item.' }, status: :forbidden
    end
  end
end