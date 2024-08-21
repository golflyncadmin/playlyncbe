class Api::V1::SessionsController < Api::ApiController

  def login
    user = User.find_by(email: params[:email])
    if user
      authentication(user)
    else
      error_response('User not found', :not_found)
    end

  rescue StandardError => e
    error_response('An error occurred during login', :internal_server_error)
  end

  private

  def authentication(user)
    if user&.valid_password?(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      success_response(true, 200, 'User logged in successfully', signin_token(user, token), status = :ok)
    else
      render json: { message: 'Please enter a valid password', prevent_token_expiry: true }, status: :unauthorized
    end
  rescue StandardError => e
    error_response('An error occurred during authentication', :internal_server_error)
  end

  def signin_token(user, token)
    user.attributes.merge(token: token)
  end
end