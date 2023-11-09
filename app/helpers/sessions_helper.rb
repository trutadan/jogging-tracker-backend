module SessionsHelper
    # Logs in the user and returns a JWT token.
    def log_in(user)
        JWT.encode({ user_id: user.id }, Rails.application.config.jwt_secret_key, 'HS256')
    end

    # Gets the current user from the JWT token.
    def current_user
        if request.headers['Authorization'].present?
            token = request.headers['Authorization'].split(' ').last
            begin
                decoded_token = JWT.decode(token, Rails.application.config.jwt_secret_key, true, { algorithm: 'HS256' })
                user_id = decoded_token.first['user_id']
                @current_user ||= User.find_by(id: user_id)
            rescue JWT::DecodeError
                @current_user = nil
            end
        end
    end        

    # Returns true if the user is logged in, false otherwise.
    def logged_in?
        !current_user.nil?
    end

    # Returns true if the given user is the current user.
    def current_user?(user)
        user && user == current_user
    end
end
    