class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: true
  validates :phone_number, uniqueness: true, if: :phone_number
  
  after_create :generate_otp
  
  def generate_otp
    self.otp = SecureRandom.random_number(100000..999999).to_s
    self.otp_expiry = 2.minutes.from_now
    save
  end
end
