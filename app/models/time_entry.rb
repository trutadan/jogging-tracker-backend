class TimeEntry < ApplicationRecord
  belongs_to :user

  default_scope -> { order(date: :desc, created_at: :desc) }

  validates :user_id, presence: true
  validates :date, presence: true
  validates :distance, presence: true, numericality: { greater_than: 0 }
  validates :hours, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :minutes, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 60 }
  validates :seconds, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 60 }
end
