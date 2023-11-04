require "test_helper"

class TimeEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @time_entry = time_entries(:one)
    @user = users(:regular_one)
    @other_user = users(:regular_two)
    @admin = users(:admin_one)
  end

  test "should get index" do
    token = log_in_as(@user)
    headers = { 'Authorization' => "Bearer #{token}" }

    get time_entries_url, headers: headers, as: :json
    assert_response :success
  end

  test "should get index for admin" do
    token = log_in_as(@admin)
    headers = { 'Authorization' => "Bearer #{token}" }

    get entries_admin_time_entries_path, headers: headers, as: :json
    assert_response :success
  end

  test "should show time_entry" do
    token = log_in_as(@user)
    headers = { 'Authorization' => "Bearer #{token}" }

    get time_entry_url(@time_entry), headers: headers, as: :json
    assert_response :success
  end

  test "should create time_entry" do
    token = log_in_as(@user)
    headers = { 'Authorization' => "Bearer #{token}" }
  
    time_entry_params = {
      date: "2023-11-06",
      distance: 2.0,
      hours: 1,
      minutes: 30,
      seconds: 0
    }
  
    assert_difference('TimeEntry.count') do
      post time_entries_url, headers: headers, params: time_entry_params, as: :json
    end
  
    assert_response :created
  end

  test "should create time_entry for admin" do
    token = log_in_as(@admin)
    headers = { 'Authorization' => "Bearer #{token}" }

    time_entry_params = {
      user_id: @user.id,
      date: "2023-11-07",
      distance: 3.0,
      hours: 2,
      minutes: 15,
      seconds: 0
    }

    assert_difference('TimeEntry.count') do
      post entries_admin_time_entries_path, headers: headers, params: time_entry_params, as: :json
    end

    assert_response :created
  end

  test "should update time_entry" do
    token = log_in_as(@user)
    headers = { 'Authorization' => "Bearer #{token}" }
    time_entry_params = {
      date: "2023-11-06",
      distance: 2.5,
      hours: 1,
      minutes: 30,
      seconds: 0
    }

    patch time_entry_url(@time_entry), headers: headers, params: time_entry_params, as: :json
    assert_response :success
    @time_entry.reload
    assert_equal 2.5, @time_entry.distance
  end

  test "should not update time_entry for another user" do
    token = log_in_as(@other_user)
    headers = { 'Authorization' => "Bearer #{token}" }
    
    time_entry_params = {
      date: "2023-11-06",
      distance: 2.5,
      hours: 1,
      minutes: 30,
      seconds: 0
    }

    patch time_entry_url(@time_entry), headers: headers, params: time_entry_params, as: :json
    assert_response :unauthorized
  end

  test "should destroy time_entry" do
    token = log_in_as(@user)
    headers = { 'Authorization' => "Bearer #{token}" }

    assert_difference('TimeEntry.count', -1) do
      delete time_entry_url(@time_entry), headers: headers, as: :json
    end

    assert_response :success
  end

  test "should not destroy time_entry for another user" do
    token = log_in_as(@other_user)
    headers = { 'Authorization' => "Bearer #{token}" }

    delete time_entry_url(@time_entry), headers: headers, as: :json
    assert_response :unauthorized
  end
end
