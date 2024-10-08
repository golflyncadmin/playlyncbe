require 'aws-sdk-sns'
require 'httparty'

class OtpService
  def initialize(user)
    @user = user
  end

  def send_phone_otp
    otp = generate_otp
    @user.update(phone_otp: otp, phone_otp_expiry: 2.minutes.from_now)
    send_sms(@user.phone_number, otp, "otp")
  end

  def send_email_otp
    otp = generate_otp
    @user.update(email_otp: otp, email_otp_expiry: 2.minutes.from_now)
    send_email(@user.email, otp, "otp")
  end

  def send_tee_times_mail
    send_email(@user.email, nil, "tee_time")
  end

  def send_tee_times_sms
    send_sms(@user.phone_number, nil, "tee_time")
  end

  private

  def generate_otp
    rand(100000..999999).to_s
  end

  def send_sms(phone_number, otp, type)
    sns = Aws::SNS::Client.new(region: ENV['AWS_REGION'], access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
    message = type == "otp" ? "Your PlayLync OTP is #{otp}" : "Tee times are available now! Book your spot from the App"
    
    sns.publish(phone_number: phone_number, message: message)
    puts "#{type.capitalize} SMS sent successfully"
  rescue Aws::SNS::Errors::ServiceError => e
    puts "Failed to send SMS #{type.capitalize}: #{e.message}"
  end

  def send_email(email, otp, type)
    event_name = type == "otp" ? "Send-OTP" : "Send SMS"
    token = ENV['KLAVIYO_API_KEY']
    user_name = otp.present? ? otp : @user.first_name

    payload = {
      token: token,
      event: event_name,
      customer_properties: { "$email" => email },
      properties: { user_name: user_name },
      time: Time.now.to_i
    }

    response = HTTParty.post('https://a.klaviyo.com/api/track', {
      headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json', 'X-Priority' => '1' },
      body: payload.to_json
    })

    if response.success?
      puts "#{type.capitalize} email sent successfully"
    else
      puts "Failed to send email #{type.capitalize}: #{response['error']}"
    end
  end
end
