class Request < ApplicationRecord
  belongs_to :user
  
  geocoded_by :location
  after_validation :geocode, if: :location_changed?

  validates :start_date, :end_date, :location, :time, :players, presence: true

  def valid_location?
    latitude.present? && longitude.present?
  end
end
