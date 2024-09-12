class Course < ApplicationRecord
  belongs_to :user

  enum status: { unapproved: 0, approved: 1 }

  validates :course_name, :course_location, presence: true
end
