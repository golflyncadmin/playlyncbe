class Admins::DashboardController < Admins::BaseController
  def index
    @total_users = User.all
    if params[:search].present?
      @users = User.search_by_full_name_and_email_and_phone_number(params[:search])
    else
      @users = User.order(created_at: :desc)
    end
  end
end
