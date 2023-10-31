require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should show user" do
    user = users(:one)
    get user_url(user), as: :json
    assert_response :success
    user_response = JSON.parse(response.body)
    assert_equal user.username, user_response['username']
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
end
