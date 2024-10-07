class Request < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :tee_times, dependent: :destroy
  
  validates :start_date, :end_date, :location, :time, :players, presence: true

  def valid_location?
    latitude.present? && longitude.present?
  end
end
