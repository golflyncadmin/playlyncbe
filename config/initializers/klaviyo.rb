require 'klaviyo-api-sdk'

KlaviyoAPI.configure do |config|
  config.api_key['Klaviyo-API-Key'] = "Klaviyo-API-Key #{ENV['KLAVIYO_API_KEY']}"
end