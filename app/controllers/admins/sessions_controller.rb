class Admins::SessionsController < Devise::SessionsController
  def create
    super do |resource|
      if resource.persisted?
        flash[:notice] = 'Signed in successfully.'
        redirect_to admins_dashboard_path and return
      end
    end
  end

  def destroy
    sign_out current_admin
    flash[:alert] = 'Signed out successfully.'
    redirect_to new_admin_session_path and return
  end
end