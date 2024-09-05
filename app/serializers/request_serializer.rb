class RequestSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :start_date, :end_date, :location, :time, :players
end
