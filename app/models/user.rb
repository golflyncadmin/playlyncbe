class User < ApplicationRecord
  include PgSearch::Model
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: true
  validates :phone_number, uniqueness: true, if: :phone_number
  
  after_create :generate_otps

  has_many :notifications, dependent: :destroy
  has_many :mobile_devices, dependent: :destroy
  has_many :tee_times, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :courses, dependent: :destroy
  
  pg_search_scope :search_by_full_name_and_email_and_phone_number,
                  against: [:first_name, :last_name, :email, :phone_number],
                  using: {
                    tsearch: { prefix: true }
                  }

  def generate_otps
    otp_service = OtpService.new(self)
    otp_service.send_phone_otp if phone_number.present?
    otp_service.send_email_otp if email.present?
  end

  def active?
    requests.exists?(["created_at > ?", 7.days.ago])
  end

  def average?
    requests.exists?(["created_at > ?", 15.days.ago]) && !active?
  end

  def not_active?
    requests.exists?(["created_at > ?", 30.days.ago]) && !active? && !average?
  end
end
