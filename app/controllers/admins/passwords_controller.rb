class Admins::PasswordsController < Devise::PasswordsController
  include ActionController::Flash
  respond_to :json

  def create
    admin = Admin.find_by(email: params[:email])
    if admin.present?
      admin.send_reset_password_instructions
      render json: { message: 'Password recovery instructions sent.' }, status: :ok
    else
      render json: { error: 'Email not found' }, status: :not_found
    end
  end
end
