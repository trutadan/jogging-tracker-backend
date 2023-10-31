require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
        @user = users(:one) 
      end
    
    test 'should log in and return success message' do
        post login_path, params: { email: @user.email, password: 'password123' }
        assert_response :success
        response_json = JSON.parse(response.body)
        assert_equal 'Logged in successfully', response_json['message']
    end

    test 'should return unauthorized for invalid login' do
        post login_path, params: { email: @user.email, password: 'invalid_password' }
        assert_response :unauthorized
        response_json = JSON.parse(response.body)
        assert_equal 'Invalid email or password', response_json['error']
    end

    test 'should log out and return success message' do
        delete logout_path
        assert_response :success
        response_json = JSON.parse(response.body)
        assert_equal 'Logged out successfully', response_json['message']
    end
end
