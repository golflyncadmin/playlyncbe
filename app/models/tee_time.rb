class TeeTime < ApplicationRecord
  belongs_to :user
  belongs_to :request

  validates :course_name, :start_time, :course_date, :booking_url, presence: true
end
