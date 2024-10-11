class Admins::PasswordsController < Devise::PasswordsController
  def create
    admin = Admin.find_by(email: params[:admin][:email])
    if admin.present?
      token = admin.send_reset_password_instructions
      otp_service = OtpService.new(admin)
      otp_service.send_reset_password_email(admin.email, edit_admin_password_url(reset_password_token: token, host: request.base_url))
      flash[:notice] = 'Password recovery instructions sent.'
      redirect_to admins_password_reset_path(resource_name, email: admin.email)
    else
      flash[:alert] = 'Email not found.'
      redirect_to new_admin_password_path
    end
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
 
    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      flash[:notice] = 'Password has been changed successfully.'
      redirect_to new_session_path(resource_name)
    else
      flash[:alert] = resource.errors.full_messages.join(', ')
      redirect_to edit_admin_password_path(reset_password_token: resource.reset_password_token)
    end
  end

  def resend
    admin = Admin.find_by(email: params[:email])
    if admin
      token = admin.send_reset_password_instructions
      otp_service = OtpService.new(admin)
      otp_service.send_reset_password_email(admin.email, edit_admin_password_url(reset_password_token: token, host: request.base_url))
      flash[:notice] = 'Reset password instructions resent.'
      redirect_to admins_password_reset_path(resource_name, email: admin.email)
    else
      flash[:alert] = 'Email not found.'
      redirect_back(fallback_location: new_session_path(resource_name))
    end
  end

  def reset
  end
 
  private
 
  def assert_reset_token_passed
    true
  end
end
