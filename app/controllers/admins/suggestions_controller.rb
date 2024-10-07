class Admins::SuggestionsController < Admins::BaseController
  def index
    @new_courses = Course.where(status: "pending").order(created_at: :desc)
    @approved_courses = Course.where(status: "approved").order(created_at: :desc)
    @declined_courses = Course.where(status: "declined").order(created_at: :desc)
    @issues = Issue.all
  end
end