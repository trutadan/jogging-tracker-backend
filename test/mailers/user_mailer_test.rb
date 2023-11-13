require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  def setup
    @user = users(:regular_one)
  end

  test 'password_reset_email' do
    # Create a user with a reset token
    @user.create_reset_digest
    @user.save!

    # Send the password reset email
    email = UserMailer.password_reset(@user).deliver_now

    # Check the subject of the email
    assert_equal 'Password reset', email.subject

    # Check that the email is sent to the correct recipient
    assert_equal [@user.email], email.to

    # Check that the email is sent from the correct address
    assert_equal [ENV['GMAIL_USERNAME']], email.from
  end
end
