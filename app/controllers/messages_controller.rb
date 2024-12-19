class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ticket
  before_action :set_message, only: [:destroy]
  before_action :authorize_access!, except: [:create]

  # GET /tickets/:ticket_id/messages
  def index
    @messages = @ticket.messages.includes(:user).order(created_at: :desc)
    render json: @messages, include: :user
  end

  # POST /tickets/:ticket_id/messages
  def create
    @message = @ticket.messages.build(message_params)
    @message.user = current_user

    if @message.save
      render json: @message, status: :created
    else
      render json: @message.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tickets/:ticket_id/messages/:id
  def destroy
    @message.destroy
    render json: { message: 'Deleted.' }, status: :ok
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
  end

  def set_message
    @message = @ticket.messages.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def authorize_access!
    if !current_user.admin? && @ticket.user != current_user
      return render json: { error: 'You are not authorized to access this item.' }, status: :forbidden
    end
  end
end