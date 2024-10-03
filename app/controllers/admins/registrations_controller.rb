class Admins::RegistrationsController < Devise::RegistrationsController
  def create
    admin = Admin.new(sign_up_params)
    if admin.save
      flash[:notice] = 'Account created successfully. Please log in.'
      redirect_to new_session_path(:admin)
    else
      flash[:alert] = admin.errors.full_messages.join(', ')
      render :new
    end
  end

  private

  def sign_up_params
    params.require(:admin).permit(:email, :password, :password_confirmation, :full_name)
  end
end
