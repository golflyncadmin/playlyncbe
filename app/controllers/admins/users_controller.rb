class Admins::UsersController < ApplicationController
  def check_email
    email = params[:email]
    admin_exists = Admin.exists?(email: email)
    render json: { exists: admin_exists }
  end
end
