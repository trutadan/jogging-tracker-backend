class API::UsersController < ApplicationController
  before_action :require_authentication, except: [:create]

  # GET /users
  def index
    if current_user&.user_manager? || current_user&.admin?
      users = User.all.order(:id).paginate(page: params[:page], per_page: 25)
      @total_pages = users.total_pages

      @users_json = users.to_json(only: [:id, :username, :email, :role])

      render json: {
        users: JSON.parse(@users_json),
        total_pages: @total_pages
      }
    else
      render_unauthorized("You do not have permission to perform this action.")
    end
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])

    if current_user?(@user) || current_user&.admin? || current_user&.user_manager?
      render json: @user
    else
      render_unauthorized("You do not have permission to view this user's details.")
    end
  end

  # POST /users
  def create
    if current_user&.admin? || current_user&.user_manager?
      @user = User.new(extended_user_params)
    else
      @user = User.new(user_params)
    end

    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])

    if current_user?(@user) || current_user&.admin? || current_user&.user_manager?
      if @user.update(current_user&.admin? || current_user&.user_manager? ? extended_user_params : user_params)
        render json: @user
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    else
      render_unauthorized("You do not have permission to update this user's details.")
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])

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

