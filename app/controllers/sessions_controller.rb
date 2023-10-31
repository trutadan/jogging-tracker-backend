class SessionsController < ApplicationController
  # POST /login
  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      log_in user
      render json: { message: 'Logged in successfully' }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  # DELETE /logout
  def destroy
    log_out
    render json: { message: 'Logged out successfully' }
  end
end
