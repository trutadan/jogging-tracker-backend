class SessionsController < ApplicationController
  # POST /login
  def create
    user = User.find_by(email: params[:email].downcase)
    if user&.authenticate(params[:password])
      log_in user
      params[:remember_me] == '1' ? remember(user) : forget(user)
      render json: { message: 'Logged in successfully' }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  # DELETE /logout
  def destroy
    log_out if logged_in?
    render json: { message: 'Logged out successfully' }
  end
end
