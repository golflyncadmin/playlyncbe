class Issue < ApplicationRecord
  validates :email, :subject, :body, presence: true

  enum status: { open: 0, archived: 1 }

  scope :new_issues, -> { where(status: :open).order(created_at: :desc) }
  scope :archived_issues, -> { where(status: :archived).order(created_at: :desc) }
end
