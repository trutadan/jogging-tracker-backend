require "test_helper"

class API::SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
        @user = users(:regular_one) 
    end

    test 'should return unauthorized for invalid login' do
        post api_login_path, params: { email: @user.email, password: 'invalid_password' }
        assert_response :unauthorized
        response_json = JSON.parse(response.body)
        assert_equal 'Invalid email or password', response_json['error']
    end

    test 'should return authorized for valid login' do
        post api_login_path, params: { email: @user.email, password: 'Pa$$w0rd' }
        assert_response :ok
    end
end