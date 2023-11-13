class UserMailer < ApplicationMailer
    FRONTEND_URL = ENV['FRONTEND_URL']
    
    def password_reset(user)
        @user = user
        @url = "#{FRONTEND_URL}/reset_password/#{user.reset_token}"
        mail to: user.email, subject: "Password reset"
    end
end
