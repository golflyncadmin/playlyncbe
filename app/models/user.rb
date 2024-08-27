class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: true
  validates :phone_number, uniqueness: true, if: :phone_number
  
  after_create :generate_otps
  
  def generate_otps
    generate_phone_otp if phone_number.present?
    generate_email_otp if email.present?
  end

  def generate_phone_otp
    self.phone_otp = SecureRandom.random_number(100000..999999).to_s
    self.phone_otp_expiry = 5.minutes.from_now
    save
  end

  def generate_email_otp
    self.email_otp = SecureRandom.random_number(100000..999999).to_s
    self.email_otp_expiry = 5.minutes.from_now
    save
  end
end
