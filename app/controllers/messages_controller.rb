class MessagesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_ticket
  
    # GET /tickets/:ticket_id/messages
    def index
      @messages = @ticket.messages.includes(:user)
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
  
    private
  
    def set_ticket
      @ticket = Ticket.find(params[:ticket_id])
    end
  
    def message_params
      params.require(:message).permit(:content)
    end
  end