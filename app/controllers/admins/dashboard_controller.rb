class Admins::DashboardController < Admins::BaseController
  def index
    @users = User.all
  end
end
