class Admins::SettingsController < Admins::BaseController

  def index
  end

  def update
    @admin = current_admin

    if password_fields_present?
      if @admin.valid_password?(params[:admin][:current_password])
        if @admin.update(admin_params)
          bypass_sign_in(@admin)
          flash[:notice] = 'Password updated successfully.'
          redirect_to admins_dashboard_index_path
        else
          flash[:alert] = @admin.errors.full_messages.join(', ')
          render :index
        end
      else
        flash[:alert] = 'Current password is incorrect.'
        render :index
      end
    else
      if @admin.update(admin_params.except(:password, :password_confirmation))
        flash[:notice] =  'Informations updated successfully.'
        redirect_to admins_dashboard_index_path
      else
        flash[:alert] = @admin.errors.full_messages.join(', ')
        render :index
      end
    end
  end

  private

  def admin_params
    params.require(:admin).permit(:full_name, :email, :password, :password_confirmation)
  end

  def password_fields_present?
    params[:admin][:password].present? || params[:admin][:password_confirmation].present?
  end
end
