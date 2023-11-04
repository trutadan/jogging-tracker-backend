class ApplicationController < ActionController::API
    include SessionsHelper
   
    private 
        def render_unauthorized(message)
            render json: { error: message }, status: :unauthorized
        end

        def require_authentication
            render_unauthorized("You must be logged in to perform this action.") unless logged_in?
        end
        
        def require_user_manager
            render_unauthorized("You do not have permission to perform this action.") unless current_user&.user_manager?
        end
        
        def require_admin
            render_unauthorized("You do not have permission to perform this action.") unless current_user&.admin?
        end
end
