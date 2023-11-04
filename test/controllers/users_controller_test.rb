require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:regular_one)
    @other_user = users(:regular_two)
    @admin = users(:admin_one)
    @user_manager = users(:user_manager_one)
  end

  test "should show user when correct regular user logged in" do
    token = log_in_as(@user)
    @headers = { 'Authorization' => "Bearer #{token}" }
    get user_url(@user), headers: @headers, as: :json
    assert_response :success
    user_response = JSON.parse(response.body)
    assert_equal @user.username, user_response['username']
  end

  test "should create user" do
    user_params = {
      user: {
        username: "new_user",
        email: "new_user@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    assert_difference('User.count') do
      post users_url, params: user_params, as: :json
    end

    assert_response :created
    user_response = JSON.parse(response.body)
    assert_equal "new_user", user_response['username']
  end

  test 'should delete user' do
    token = log_in_as(@admin)
    headers = { 'Authorization' => "Bearer #{token}" }

    assert_difference('User.count', -1) do
      delete user_url(@user), headers: headers, as: :json
    end

    assert_response :success
  end

  test 'should update user' do
    token = log_in_as(@admin)
    headers = { 'Authorization' => "Bearer #{token}" }

    updated_username = 'updated_username'

    assert_changes('@user.reload.username', from: @user.username, to: updated_username) do
      patch user_url(@user), headers: headers, params: { user: { username: updated_username } }, as: :json
    end

    assert_response :success
  end

  test 'should not access any action other than create when user not logged in' do
    get users_url, headers: @headers, as: :json
    assert_response :unauthorized

    get user_url(@user), headers: @headers, as: :json
    assert_response :unauthorized

    patch user_path(@user), headers: @headers, params: { user: { username: @user.username, email: @user.email } }
    assert_response :unauthorized

    delete user_url(@user), headers: @headers, as: :json
    assert_response :unauthorized
  end

  test "should return unauthorized when regular user logged in as wrong user" do
    token = log_in_as(@other_user)
    @headers = { 'Authorization' => "Bearer #{token}" }

    patch user_path(@user), headers: @headers, params: { user: { username: @user.username, email: @user.email } }
    assert_response :unauthorized

    get user_url(@user), headers: @headers, as: :json
    assert_response :unauthorized
  end

  test "regular user should not access moderator/admin actions " do
    token = log_in_as(@user)
    @headers = { 'Authorization' => "Bearer #{token}" }
  
    get users_url, headers: @headers, as: :json
    assert_response :unauthorized
  
    delete user_url(@other_user), headers: @headers, as: :json
    assert_response :unauthorized
  end

  test "admin should access all actions" do
    token = log_in_as(@admin)
    @headers = { 'Authorization' => "Bearer #{token}" }
  
    get users_url, headers: @headers, as: :json
    assert_response :success

    get user_url(@user), headers: @headers, as: :json
    assert_response :success

    patch user_path(@user), headers: @headers, params: { user: { username: @user.username, email: @user.email } }
    assert_response :success

    delete user_url(@user), headers: @headers, as: :json
    assert_response :success
  end

  test "user moderator should access all actions" do
    token = log_in_as(@user_manager)
    @headers = { 'Authorization' => "Bearer #{token}" }
  
    get users_url, headers: @headers, as: :json
    assert_response :success

    get user_url(@user), headers: @headers, as: :json
    assert_response :success

    patch user_path(@user), headers: @headers, params: { user: { username: @user.username, email: @user.email } }
    assert_response :success

    delete user_url(@user), headers: @headers, as: :json
    assert_response :success
  end
end
