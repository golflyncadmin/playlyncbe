class Course < ApplicationRecord
  belongs_to :user
  has_many :requests

  enum status: { pending: 0, approved: 1, declined: 2 }

  validates :course_name, :course_location, presence: true

  scope :pending, -> { where(status: "pending").order(created_at: :desc) }
  scope :approved, -> { where(status: "approved").order(created_at: :desc) }
  scope :declined, -> { where(status: "declined").order(created_at: :desc) }

  scope :frequently_booked, -> {
    joins(:requests)
      .where('requests.created_at > ?', 1.month.ago)
      .select('courses.*, COUNT(requests.id) AS request_count')
      .group('courses.id')
      .order('request_count ASC')
  }

  scope :recently_searched, -> {
    joins(:requests)
      .where('requests.created_at > ?', 2.days.ago)
      .select('courses.*, COUNT(requests.id) AS request_count')
      .group('courses.id')
      .order('request_count ASC')
  }
end
