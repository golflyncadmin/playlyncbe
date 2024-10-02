class Admins::RegistrationsController < Devise::RegistrationsController
  # include ActionController::Flash
  respond_to :json

  def create
    admin = Admin.new(sign_up_params)
    if admin.save
      render json: { message: 'Admin created successfully.', admin: admin }, status: :created
    else
      render json: { errors: admin.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require(:admin).permit(:email, :password, :password_confirmation)
  end
end
