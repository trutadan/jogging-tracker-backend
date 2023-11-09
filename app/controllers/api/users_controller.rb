class API::UsersController < ApplicationController
  before_action :require_authentication, except: [:create]
  before_action :require_admin, only: [:autocomplete]

  # GET /users
  def index
    # If the user is an admin or user manager, they can view all users
    if current_user&.user_manager? || current_user&.admin?
      @users = User.all.order(:id).paginate(page: params[:page], per_page: 25)
      @total_pages = @users.total_pages

      render json: {
        # Only return the id, username, email, and role of each user
        users: JSON.parse(@users.to_json(only: [:id, :username, :email, :role])),
        total_pages: @total_pages
      }
    else
      render_unauthorized("You do not have permission to perform this action.")
    end
  end

  # GET /users/autocomplete
  def autocomplete
    if params[:query]
      query = params[:query]
      # Search for users whose usernames contain the query string
      # Only return the id and username of the first 20 users
      @users = User.where("username ILIKE ?", "%#{query}%").order(:username).limit(20)
      render json: JSON.parse(@users.to_json(only: [:id, :username]))
    end
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])

    if @user
      # If the user is an admin or user manager, they can view all users details, including their roles
      if current_user&.admin? || current_user&.user_manager?
        render json: JSON.parse(@user.to_json(only: [:id, :username, :email, :role])) 
      # If the user is regular, he can only view his own details
      elsif current_user?(@user)
        render json: JSON.parse(@user.to_json(only: [:id, :username, :email]))
      else
        render_unauthorized("You do not have permission to view this user's details.")
      end
    else
      render_not_found("User not found.")
    end
  end

  # POST /users
  def create
    # If the user is an admin or user manager, they can create users with the following attributes: username, email, password, password_confirmation, and role
    if current_user&.admin?
      # Admins can create users with any role
      @user = User.new(extended_user_params)
    elsif current_user&.user_manager?
      # User managers can create users with roles "regular" or "user_manager", but not "admin"
      if extended_user_params[:role] != "admin"
        @user = User.new(extended_user_params)
      else
        render json: { error: "User managers cannot create users with the 'admin' role." }, status: :unprocessable_entity
      end
    else
      # Unauthenticated users can create users which will have the "regular" role initially
      @user = User.new(user_params)
    end

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    @user = User.find(params[:id])

    if @user
      # User managers can update any user's details
      if current_user&.user_manager?
        # User managers can update users with roles "regular" or "user_manager", but not "admin"
        if extended_user_params[:role] != "admin"
          if @user.update(extended_user_params)
            render json: @user
          else
            render json: @user.errors, status: :unprocessable_entity
          end
        else
          render json: { error: "User managers cannot create users with the 'admin' role." }, status: :unprocessable_entity
        end
        
      # Admins can update any user's details
      # Regular users can only update their own details, except for their role
      elsif current_user&.admin? || current_user?(@user)
        if @user.update(current_user&.admin? ? extended_user_params : user_params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_entity
        end
        
      else
        render_unauthorized("You do not have permission to update this user's details.")
      end
    else
      render_not_found("User not found.")
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])

    # If the user is an admin or user manager, they can delete any user
    if current_user&.admin? || current_user&.user_manager?
      @user.destroy
      render json: { message: 'User has been deleted' }
    else
      render_unauthorized("You do not have permission to delete this user.")
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end

    def extended_user_params
      params.require(:user).permit(:username, :email, :role, :password, :password_confirmation)
    end
end

