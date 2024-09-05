Geocoder.configure(
  timeout: 5,  
  lookup: :google,
  api_key: ENV['GOOGLE_API_KEY'],
  units: :km,     
  cache: Redis.new,
  cache_prefix: "geocoder:",
  expiration: nil
)