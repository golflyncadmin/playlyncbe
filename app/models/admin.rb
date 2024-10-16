class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

	validates :full_name, presence: true,
                      format: { with: /\A[A-Za-z][A-Za-z0-9\s]*\z/, message: "contains only alphabets and numbers." },
                      length: { maximum: 25 }

	def send_reset_password_instructions
		set_reset_password_token
	end
end
