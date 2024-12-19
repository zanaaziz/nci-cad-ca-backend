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

    is_first_message = @ticket.messages.count.zero?

    if is_first_message
      sentiment = open_ai_analyse(@message.content)
      sentiment = sentiment[:data]['choices'][0]['message']['content']

      @ticket.update(sentiment: sentiment)
    end

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

  def open_ai_analyse(content)
    open_ai_token = Rails.application.credentials.open_ai_secret

    response = Faraday.post('https://api.openai.com/v1/chat/completions') do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{open_ai_token}"

      req.body = {
        "model": "gpt-4o-mini",
        "messages": [
            {
              "role": "developer",
              "content": "Your role is to perform sentiment analysis on what is sent to you and respond with an integer between 0 and 10."
            },
            {
              "role": "user",
              "content": content
            }
        ]
      }.to_json
    end
  
    if response.status == 200
      response_body = JSON.parse(response.body)
      { success: true, data: response_body }
    else
      { success: false, data: nil }
    end

  rescue Faraday::Error => e
    Rails.logger.error "Third-party request failed: #{e.message}"
    { success: false, data: nil }
  end
end