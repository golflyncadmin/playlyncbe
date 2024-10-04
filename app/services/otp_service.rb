require 'aws-sdk-sns'
require 'httparty'

class OtpService
  
  def initialize(user)
    @user = user
  end

  def send_phone_otp
    otp = generate_otp
    @user.update(phone_otp: otp, phone_otp_expiry: 2.minutes.from_now)
    send_sms(@user.phone_number, otp)
  end

  def send_email_otp
    otp = generate_otp
    @user.update(email_otp: otp, email_otp_expiry: 2.minutes.from_now)
    send_email(@user.email, otp)
  end

  private

  def generate_otp
    rand(100000..999999).to_s
  end

  def send_sms(phone_number, otp)
    sns = Aws::SNS::Client.new(region: ENV['AWS_REGION'], access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
    message = "Your PlayLync OTP is #{otp}"
    sns.publish(phone_number: phone_number, message: message)
    Rails.logger.info "Mobile otp sent successfully"
  rescue Aws::SNS::Errors::ServiceError => e
    Rails.logger.error "Failed to send SMS OTP: #{e.message}"
  end

  def send_email(email, otp, variables = {})
    event_name = "Send-OTP"
    token = ENV['KLAVIYO_API_KEY']
    
    payload = {
      token: token,
      event: event_name,
      customer_properties: {
        "$email" => email
      },
      properties: { otp: otp },
      time: Time.now.to_i
    }

    response = HTTParty.post('https://a.klaviyo.com/api/track', {
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'X-Priority' => '1'
      },
      body: payload.to_json
    })

    if response.success?
      Rails.logger.info "Email Otp sent successfully"
    else
      { error: response['error'] }
    end
  end


end
