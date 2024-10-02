class Admins::SessionsController < Devise::SessionsController
  # include ActionController::Flash
  respond_to :json

  def create
    admin = Admin.find_by(email: admin_params[:email])
    if admin&.valid_password?(admin_params[:password])
      sign_in admin
      render json: { message: 'Signed in successfully.', admin: admin }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def destroy
    sign_out current_admin
    render json: { message: 'Signed out successfully.' }, status: :ok
  end

  private

  def admin_params
    params.require(:admin).permit(:email, :password)
  end
end

