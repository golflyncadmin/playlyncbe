class NotificationService
  def initialize(user, subject, body, type)
    @subject = subject
    @user = user
    @body = body
    @type = type
  end

  # Create notifications for each device separately
  def create_notification
    mobile_tokens = fetch_mobile_tokens
    notification_ids = []

    mobile_tokens.each do |token|
      if send_push_notification(token)
        notification = Notification.create!(user_id: @user.id, subject: @subject, body: @body)
        notification_ids << notification.id
      end
    end

    Rails.logger.info notification_ids
  end

  private

  # Get device tokens
  def fetch_mobile_tokens
    @user.mobile_devices.pluck(:mobile_token)
  end

  # Send push notification to a single token
  def send_push_notification(token)
    response = notification_api(token)
    parsed_response = parse_response(response)
    parsed_response['error'].nil? && parsed_response['name']
  rescue StandardError => e
    Rails.looger.info "Notification sending failed for token #{token} of user #{@user.id}, exception: #{e}"
    false
  end

  # Send API request for notification
  def notification_api(token)
    http_request(
      uri: notification_uri,
      headers: { 'Content-Type': 'application/json', 'Authorization': "Bearer #{fetch_access_token}" },
      body: notification_body(token).to_json
    )
  end

  # Set notification URI
  def notification_uri
    URI.parse("#{ENV['NOTIFICATION_MAIN_API']}/#{ENV['PROJECT_ID']}/#{ENV['NOTIFICATION_SEND_API']}")
  end

  # Get FCM token
  def fetch_access_token
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(Rails.root.join('config', 'firebase_key.json')),
      scope: ENV['NOTIFICATION_SCOPE']
    )
    authorizer.fetch_access_token!['access_token']
  end

  # Set notification body
  def notification_body(token)
    {
      message: {
        token: token,
        notification: {
          title: @subject,
          body: @body
        },
        data: { priority: 'high', type: @type }
      }
    }
  end

  # Send HTTP request
  def http_request(uri:, headers:, body:)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = body
    http.request(request)
  end

  # Parse response
  def parse_response(response)
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise StandardError, "Failed to parse response: #{e.message}"
  end
end
