require "test_helper"

class TimeEntryTest < ActiveSupport::TestCase
  def setup
    @time_entry1 = time_entries(:one)
    @time_entry2 = time_entries(:two)
  end

  test 'should be valid' do
    assert @time_entry1.valid?
  end

  test 'user should be present' do
    @time_entry1.user = nil
    assert_not @time_entry1.valid?
  end

  test 'date should be present' do
    @time_entry1.date = nil
    assert_not @time_entry1.valid?
  end

  test 'distance should be greater than 0' do
    @time_entry1.distance = 0
    assert_not @time_entry1.valid?
  end

  test 'hours should be greater than or equal to 0' do
    @time_entry1.hours = -1
    assert_not @time_entry1.valid?
  end

  test 'minutes should be greater than or equal to 0' do
    @time_entry1.minutes = -1
    assert_not @time_entry1.valid?
  end

  test 'minutes should be less than 60' do
    @time_entry1.minutes = 60
    assert_not @time_entry1.valid?
  end

  test 'seconds should be greater than or equal to 0' do
    @time_entry1.seconds = -1
    assert_not @time_entry1.valid?
  end

  test 'seconds should be less than 60' do
    @time_entry1.seconds = 60
    assert_not @time_entry1.valid?
  end

  test 'default scope should order by created_at in descending order' do 
    time_entries = TimeEntry.all
  
    assert_equal @time_entry1, time_entries.last
    assert_equal @time_entry2, time_entries.first
  end
end
