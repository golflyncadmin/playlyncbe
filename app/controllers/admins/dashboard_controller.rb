class Admins::DashboardController < Admins::BaseController
  def index
    @users = User.all
  end

  def suggestions
  end

  def settings
  end
end
