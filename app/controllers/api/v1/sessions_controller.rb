class Api::V1::SessionsController < Api::ApiController
  before_action :find_user

  # Sign In user
  def login
    if @user
      @user.mobile_devices.find_or_create_by(mobile_token: params[:fcm_token])
      authentication
    else
      error_response('User not found', :not_found)
    end

  rescue StandardError => e
    error_response('An error occurred during login', :internal_server_error)
  end

  # Destroy user session
  def logout
    if @user
      @user.update(updated_at: Time.now)
      success_response('User logged out successfully', {}, :ok)
    else
      error_response('No user found agains this email.', :unauthorized)
    end
  end

  private

  # Authenticate User before sign in
  def authentication
    if @user&.valid_password?(params[:password])
      otp_service = OtpService.new(@user)

      if !@user.phone_verified && !@user.email_verified
        otp_service.send_phone_otp if @user.phone_number.present?
        otp_service.send_email_otp if @user.email.present?
        success_response("Please verify both your phone number and email before login. OTPs have been sent.", UserSerializer.new(@user), :unprocessable_entity)
      elsif !@user.phone_verified
        otp_service.send_phone_otp if @user.phone_number.present?
        success_response("Please verify your phone number before login. An OTP has been sent to your phone.", UserSerializer.new(@user), :unprocessable_entity)
      elsif !@user.email_verified
        otp_service.send_email_otp if @user.email.present?
        success_response("Please verify your email before login. An OTP has been sent to your email.", UserSerializer.new(@user), :unprocessable_entity)
      else
        token = JsonWebToken.encode(user_id: @user.id)
        user_json = UserSerializer.new(@user).as_json
        success_response('User logged in successfully', user_json.merge({ token: token }), :ok)
      end
    else
      render json: { message: 'Please enter a valid password', prevent_token_expiry: true }, status: :unauthorized
    end
  rescue StandardError => e
    error_response("An error occurred during authentication: #{e.message}", :internal_server_error)
  end

  def find_user
    @user = User.find_by(email: params[:email])
  end
end