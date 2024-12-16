class Users::SessionsController < Devise::SessionsController
  private

  # Custom response for successful login
  def respond_with(resource, _opts = {})
    render json: {
      message: 'Logged in successfully',
      token: request.env['warden-jwt_auth.token'], # Include the issued JWT token
      user: { id: resource.id, email: resource.email, role: resource.role }
    }, status: :ok
  end

  # Custom response for successful logout
  def respond_to_on_destroy
    render json: { message: 'Logged out successfully' }, status: :ok
  end
end