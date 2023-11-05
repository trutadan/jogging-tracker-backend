class API::SessionsController < ApplicationController
  # POST /login
  def create
    user = User.find_by(email: params[:email].downcase)
    if user&.authenticate(params[:password])
      token = log_in(user)
      render json: { message: 'Logged in successfully', token: token, user_id: user.id, username: user.username, role: user.role }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end