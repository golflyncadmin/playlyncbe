class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :phone_number, :phone_otp, :phone_otp_expiry,
             :email_otp, :email_otp_expiry, :phone_verified, :email_verified
end
