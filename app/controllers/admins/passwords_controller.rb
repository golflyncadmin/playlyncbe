class Admins::PasswordsController < Devise::PasswordsController
  @@admin_email = nil

  def create
    admin = Admin.find_by(email: params[:admin][:email])
    @@admin_email = admin if admin.present?
    if admin.present?
      token = admin.send_reset_password_instructions
      otp_service = OtpService.new(admin)
      otp_service.send_reset_password_email(admin.email, edit_password_url(admin, reset_password_token: token))
      flash[:notice] = 'Password recovery instructions sent.'
      redirect_to admins_password_reset_path(resource_name)
    else
      flash[:alert] = 'Email not found.'
      redirect_to new_admin_password_path
    end
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.valid_password?(resource_params[:password])
      flash[:alert] = "You cannot reuse your previous password. Please choose a different one."
      redirect_to edit_admin_password_path(reset_password_token: resource.reset_password_token)
      return
    end

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
    admin = Admin.find_by(email: @@admin_email.email)
    if admin
      token = admin.send_reset_password_instructions
      otp_service = OtpService.new(admin)
      otp_service.send_reset_password_email(admin.email, edit_password_url(admin, reset_password_token: token))
      flash[:notice] = 'Reset password instructions resent.'
      redirect_to admins_password_reset_path(resource_name)
    else
      flash[:alert] = 'Email not found.'
      redirect_back(fallback_location: new_session_path(resource_name))
    end
  end
  def reset
  end
end
