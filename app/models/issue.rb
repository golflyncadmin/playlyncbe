class Issue < ApplicationRecord
  validates :email, :subject, :body, presence: true
end
