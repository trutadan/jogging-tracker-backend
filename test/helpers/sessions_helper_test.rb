require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  def setup
    @user = users(:regular_one)
  end

  test "log_in method returns a JWT token" do
    token = log_in_as(@user)
    assert_not_nil token
  end

  test "current_user returns the user from a valid token" do
    token = log_in_as(@user)
    @request.headers['Authorization'] = "Bearer #{token}"
    assert_equal @user, current_user
  end

  test "current_user returns nil for an invalid token" do
    @request.headers['Authorization'] = 'Bearer invalid_token'
    assert_nil current_user
  end

  test "logged_in? returns true for a logged-in user" do
    token = log_in_as(@user)
    @request.headers['Authorization'] = "Bearer #{token}"
    assert logged_in?
  end

  test "logged_in? returns false for an invalid token" do
    @request.headers['Authorization'] = 'Bearer invalid_token'
    assert_not logged_in?
  end
end
