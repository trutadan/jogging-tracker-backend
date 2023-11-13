class API::PasswordResetsController < ApplicationController
  def create
    # Find user by email address
    user = User.find_by(email: params[:email].downcase)

    # If user is found, create a reset digest and send an email to the user
    if user
      user.create_reset_digest
      user.send_password_reset_email
      render json: { message: "We have sent you an email to your registered email address, please follow the instruction to reset your password." }, status: :created
    else
      render json: { error: "Email address not registered" }, status: :not_found
    end
  end

  def update
    # Find user by email address
    user = User.find_by(email: params[:email].downcase)

    # If password is empty, return error
    if params[:credentials][:password].empty?
      render json: { error: "Password can't be empty." }, status: :unprocessable_entity
    end 

    # The user must be found by email
    if user
      # If the reset token is not expired and the user is authenticated, reset the password
      if user.reset_sent_at && user.reset_sent_at + 7200 >= Time.zone.now && user.authenticated?(:reset, params[:id])
        user.reset_password(user_params)
        render json: { message: "Your password has been reset." }, status: :created
      else
        render json: { error: "Token has expired." }, status: :unprocessable_entity
      end
    else
      render json: { error: "Email address not registered." }, status: :not_found
    end
  end
    
  private
    def user_params
      params.require(:credentials).permit(:password, :password_confirmation)
    end
end
