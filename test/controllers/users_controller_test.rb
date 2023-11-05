require "test_helper"

class API::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:regular_one)
    @other_user = users(:regular_two)
    @admin = users(:admin_one)
    @user_manager = users(:user_manager_one)
  end

  test "should show user when correct regular user logged in" do
    token = log_in_as(@user)
    @headers = { 'Authorization' => "Bearer #{token}" }
    get api_user_url(@user), headers: @headers, as: :json
    assert_response :success
    user_response = JSON.parse(response.body)
    assert_equal @user.username, user_response['username']
  end

  test "should create user" do
    user_params = {
      user: {
        username: "new_user",
        email: "new_user@example.com",
        password: "Pa$$w0rd",
        password_confirmation: "Pa$$w0rd"
      }
    }

    assert_difference('User.count') do
      post api_users_url, params: user_params, as: :json
    end

    assert_response :created
    user_response = JSON.parse(response.body)
    assert_equal "new_user", user_response['username']
  end

  test 'should delete user' do
    token = log_in_as(@admin)
    headers = { 'Authorization' => "Bearer #{token}" }

    assert_difference('User.count', -1) do
      delete api_user_url(@user), headers: headers, as: :json
    end

    assert_response :success
  end

  test 'should update user' do
    token = log_in_as(@admin)
    headers = { 'Authorization' => "Bearer #{token}" }

    updated_username = 'updated_username'

    assert_changes('@user.reload.username', from: @user.username, to: updated_username) do
      patch api_user_url(@user), headers: headers, params: { user: { username: updated_username } }, as: :json
    end

    assert_response :success
  end

  test 'should not access any action other than create when user not logged in' do
    get api_users_url, headers: @headers, as: :json
    assert_response :unauthorized

    get api_user_url(@user), headers: @headers, as: :json
    assert_response :unauthorized

    patch api_user_path(@user), headers: @headers, params: { user: { username: @user.username, email: @user.email } }
    assert_response :unauthorized

    delete api_user_url(@user), headers: @headers, as: :json
    assert_response :unauthorized
  end

  test "should return unauthorized when regular user logged in as wrong user" do
    token = log_in_as(@other_user)
    @headers = { 'Authorization' => "Bearer #{token}" }

    patch api_user_path(@user), headers: @headers, params: { user: { username: @user.username, email: @user.email } }
    assert_response :unauthorized

    get api_user_url(@user), headers: @headers, as: :json
    assert_response :unauthorized
  end

  test "regular user should not access moderator/admin actions " do
    token = log_in_as(@user)
    @headers = { 'Authorization' => "Bearer #{token}" }
  
    get api_users_url, headers: @headers, as: :json
    assert_response :unauthorized
  
    delete api_user_url(@other_user), headers: @headers, as: :json
    assert_response :unauthorized
  end

  test "admin should access all actions" do
    token = log_in_as(@admin)
    @headers = { 'Authorization' => "Bearer #{token}" }
  
    get api_users_url, headers: @headers, as: :json
    assert_response :success

    get api_user_url(@user), headers: @headers, as: :json
    assert_response :success

    patch api_user_path(@user), headers: @headers, params: { user: { username: @user.username, email: @user.email } }
    assert_response :success

    delete api_user_url(@user), headers: @headers, as: :json
    assert_response :success
  end

  test "user moderator should access all actions" do
    token = log_in_as(@user_manager)
    @headers = { 'Authorization' => "Bearer #{token}" }
  
    get api_users_url, headers: @headers, as: :json
    assert_response :success

    get api_user_url(@user), headers: @headers, as: :json
    assert_response :success

    patch api_user_path(@user), headers: @headers, params: { user: { username: @user.username, email: @user.email } }
    assert_response :success

    delete api_user_url(@user), headers: @headers, as: :json
    assert_response :success
  end
end
