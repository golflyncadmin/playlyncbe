require 'aws-sdk-sns'
require 'httparty'

class OtpService
  def initialize(user)
    @user = user
  end

  # Send Phone OTP
  def send_phone_otp
    otp = generate_otp
    @user.update(phone_otp: otp, phone_otp_expiry: 2.minutes.from_now)
    send_sms(@user.phone_number, otp, "otp")
  end

  # Send Email OTP
  def send_email_otp
    otp = generate_otp
    @user.update(email_otp: otp, email_otp_expiry: 2.minutes.from_now)
    send_email(email: @user.email, type: "otp", otp: otp)
  end

  # Reminder email for tee times
  def send_tee_times_mail
    send_email(email: @user.email, type: "tee_time", user_name: @user.first_name)
  end

  # Reminder SMS for tee times
  def send_tee_times_sms
    send_sms(@user.phone_number, nil, "tee_time")
  end

  # Send custom email
  def send_custom_email(email, message_content)
    send_email(email: email, type: "custom", custom_message: message_content)
  end

  private

  # Generate random OTP
  def generate_otp
    rand(100000..999999).to_s
  end

  def send_sms(phone_number, otp, type)
    sns = Aws::SNS::Client.new(
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
    
    message = case type
              when "otp" then "Your PlayLync OTP is #{otp}"
              else "Tee times are available now! Book your spot from the App"
              end

    sns.publish(phone_number: phone_number, message: message)
    puts "#{type.capitalize} SMS sent successfully"
  rescue Aws::SNS::Errors::ServiceError => e
    puts "Failed to send SMS #{type.capitalize}: #{e.message}"
  end

  def send_email(email:, type:, otp: nil, user_name: nil, custom_message: nil)
    event_name = case type
                 when "otp" then "Send-OTP"
                 when "tee_time" then "Send SMS"
                 else "Custom Message"
                 end

    token = ENV['KLAVIYO_API_KEY']
    message_content = custom_message || "Default message"

    user_display_name = user_name || otp || ""

    payload = {
      token: token,
      event: event_name,
      customer_properties: { "$email" => email },
      properties: { user_name: user_display_name, message: message_content },
      time: Time.now.to_i
    }

    response = HTTParty.post('https://a.klaviyo.com/api/track', {
      headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json', 'X-Priority' => '1' },
      body: payload.to_json
    })

    if response.success?
      puts "#{type.capitalize} email sent successfully"
      true
    else
      puts "Failed to send #{type.capitalize} email: #{response['error']}"
      false
    end
  rescue StandardError => e
    puts "An error occurred while sending #{type.capitalize} email: #{e.message}"
  end
end
