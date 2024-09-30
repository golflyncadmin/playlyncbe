class MobileDevice < ApplicationRecord
  belongs_to :user
  validates :mobile_token, presence: true
end