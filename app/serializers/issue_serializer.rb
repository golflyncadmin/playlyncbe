class IssueSerializer < ActiveModel::Serializer
  attributes :id, :email, :subject, :body, :created_at
end
