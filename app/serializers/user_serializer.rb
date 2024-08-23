class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :full_name, :phone_number, :otp, :otp_expiry, :verified
end
