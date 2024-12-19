class Users::SessionsController < Devise::SessionsController
  private

  def respond_with(resource, _opts = {})
    render json: {
      message: 'Logged in successfully',
      token: request.env['warden-jwt_auth.token'],
      user: { id: resource.id, email: resource.email, role: resource.role }
    }, status: :ok
  end

  def respond_to_on_destroy
    render json: { message: 'Logged out successfully' }, status: :ok
  end
end