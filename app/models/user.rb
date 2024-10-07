class User < ApplicationRecord
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
  
  def generate_otps
    otp_service = OtpService.new(self)
    otp_service.send_phone_otp if phone_number.present?
    otp_service.send_email_otp if email.present?
  end

  def active?
    requests.exists?(["created_at > ?", 30.days.ago])
  end
end
