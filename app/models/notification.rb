class Notification < ApplicationRecord
  belongs_to :user

  def self.send_and_create_notification(user, subject, body)
    notification = Notification.new(user: user, subject: subject, body: body)
    
    if notification.send_notification
      notification.save!
    end
  end

  def send_notification
    mobile_tokens = fetch_mobile_tokens
    return false unless mobile_tokens.present?
    
    responses = mobile_tokens.map { |token| send_push_notification(token) }
    handle_responses(responses)

    true
  rescue StandardError => e
    puts "Notification sending failed for user #{user.id}"
    false
  end

  private

  def fetch_mobile_tokens
    user.mobile_devices.pluck(:mobile_token)
  end

  def send_push_notification(token)
    response = notification_api(token)
    parsed_response = parse_response(response)
    if parsed_response['error'].nil? && parsed_response['name']
      # puts parsed_response
      { success: true, message: 'Notification sent successfully' }
    else
      raise StandardError, "#{parsed_response['error']['message']}"
    end
  end

  def notification_api(token)
    http_request(
      uri: notification_uri,
      headers: { 'Content-Type': 'application/json', 'Authorization': "Bearer #{fetch_access_token}" },
      body: notification_body(token).to_json
    )
  end

  def notification_uri
    URI.parse("#{ENV['NOTIFICATION_MAIN_API']}/#{ENV['PROJECT_ID']}/#{ENV['NOTIFICATION_SEND_API']}")
  end

  def fetch_access_token
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(Rails.root.join('config', 'firebase_key.json')),
      scope: ENV['NOTIFICATION_SCOPE']
    )
    authorizer.fetch_access_token!['access_token']
  end

  def notification_body(token)
    {
      message: {
        token: token,
        notification: {
          title: subject,
          body: body
        },
        data: { priority: 'high' }
      }
    }
  end

  def http_request(uri:, headers:, body:)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = body
    http.request(request)
  end

  def parse_response(response)
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise StandardError, "Failed to parse response: #{e.message}"
  end

  def handle_responses(responses)
    responses.each do |response|
      next if response[:success]

      puts "Error during notification sending: #{response[:message]}"
    end
  end
end
