class Api::V1::SessionsController < Api::ApiController
  before_action :find_user

  def login
    if @user
      authentication
    else
      error_response('User not found', :not_found)
    end

  rescue StandardError => e
    error_response('An error occurred during login', :internal_server_error)
  end

  def logout
    if @user
      @user.update(updated_at: Time.now)
      success_response('User logged out successfully', {})
    else
      error_response('No user found agains this email.', :unauthorized)
    end
  end

  private

  def authentication
    if @user&.valid_password?(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      user_json = UserSerializer.new(@user).as_json
      success_response('User logged in successfully', user_json.merge({ token: token }), status = :ok)
    else
      render json: { message: 'Please enter a valid password', prevent_token_expiry: true }, status: :unauthorized
    end
  rescue StandardError => e
    error_response("An error occurred during authentication #{e}", :internal_server_error)
  end

  def find_user
    @user = User.find_by(email: params[:email])
  end
end