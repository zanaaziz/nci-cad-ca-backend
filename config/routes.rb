Rails.application.routes.draw do
  # Configures Devise for user authentication, specifying JSON as the default format.
  # Overrides the default sessions controller with a custom one for JWT authentication.
  devise_for :users, defaults: { format: :json }, controllers: {
    sessions: 'users/sessions',
  }
  
  # Defines RESTful routes for tickets and nested messages.
  # Allows actions like create, index, and destroy for messages within a specific ticket.
  resources :tickets do
    resources :messages, only: %i[create index destroy]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end