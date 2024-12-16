# Helper module for handling authentication in tests
module AuthHelpers
  # Generates an authentication header for a given user
  #
  # @param user [User] The user to authenticate
  # @return [Hash] Headers with the generated JWT token
  def authenticate_user(user)
    # Encodes the user into a JWT token using Warden
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first

    # Returns the Authorization header with the token
    { 'Authorization' => "Bearer #{token}" }
  end
end