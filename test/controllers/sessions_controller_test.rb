require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
        @user = users(:one) 
    end

    test 'should return unauthorized for invalid login' do
        post login_path, params: { email: @user.email, password: 'invalid_password' }
        assert_response :unauthorized
        response_json = JSON.parse(response.body)
        assert_equal 'Invalid email or password', response_json['error']
    end
end
