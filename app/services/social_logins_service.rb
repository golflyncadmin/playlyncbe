class SocialLoginsService
  require 'net/http'
  require 'net/https'
  require 'open-uri'
  require 'jwt'

  PASSWORD_DIGEST = SecureRandom.hex(10)
  APPLE_PEM_URL = 'https://appleid.apple.com/auth/keys'

  def initialize(provider, token, fcm_token)
    @token = token
    @provider = provider.downcase
    @fcm_token = fcm_token
  end

  def social_login
    send("#{@provider}_signup")
  end

  private

  def google_signup
    uri = URI("https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{@token}")
    process_signup(uri)
  end

  def facebook_signup
    uri = URI("https://graph.facebook.com/v13.0/me?fields=name,email&access_token=#{@token}")
    process_signup(uri)
  end

  def apple_signup
    begin
      token_data = decode_apple_token
      create_user(token_data)
    rescue StandardError => e
      return e.message
    end
  end

  def process_signup(uri)
    response = Net::HTTP.get_response(uri)
    return JSON.parse(response.body) unless response.is_a?(Net::HTTPSuccess)

    json_response = JSON.parse(response.body).with_indifferent_access
    create_user(json_response)
  rescue JSON::ParserError => e
    return e.message
  end

  def decode_apple_token
    header_segment = JSON.parse(Base64.decode64(@token.split('.').first))
    apple_response = Net::HTTP.get(URI.parse(APPLE_PEM_URL))
    apple_certificate = JSON.parse(apple_response)

    key_hash = apple_certificate['keys'].find { |key| key['kid'] == header_segment['kid'] }
    jwk = JWT::JWK.import(key_hash)
    JWT.decode(@token, jwk.public_key, true, { algorithm: header_segment['alg'] }).first
  end

  def create_user(response)
    user = User.find_or_initialize_by(email: response['email'])
    user.assign_attributes(
      first_name: response['name'],
      password: PASSWORD_DIGEST,
      password_confirmation: PASSWORD_DIGEST
    )

    if @fcm_token
      user.mobile_devices.find_or_create_by(mobile_token: @fcm_token)
    end

    user.save! if user.new_record? || user.changed?
    token = JsonWebToken.encode(user_id: user.id)
    [user, token]
  end
end
