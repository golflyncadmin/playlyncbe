class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :full_name, presence: true,
                        format: { with: /\A[A-Za-z][A-Za-z\s]*\z/, message: "must start with letter" },
                        length: { maximum: 25 }
end
