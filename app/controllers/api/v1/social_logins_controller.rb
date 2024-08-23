class Api::V1::SocialLoginsController < Api::ApiController
  
  def social_login
    provider = params['provider']
    token = params['token']

    unless provider.present? && ['google', 'apple', 'facebook'].include?(provider)
      error_response('Provider not specified or invalid', :bad_request) 
    end
    
    response = SocialLoginsService.new(provider, token).social_login
    user = response.is_a?(Array) ? response.first : nil
    auth_token = response.is_a?(Array) ? response.last : nil

    if user
      user_json = UserSerializer.new(response.first).as_json
      success_response('Logged in successfully', user_json.merge({ token: response.last }))
    else
      error_response(response, :unprocessable_entity)
    end
  end
end
