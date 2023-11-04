ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    # Logs in the user and returns a JWT token.
    def log_in_as(user)
        JWT.encode({ user_id: user.id }, Rails.application.config.jwt_secret_key, 'HS256')
    end
  end
end
