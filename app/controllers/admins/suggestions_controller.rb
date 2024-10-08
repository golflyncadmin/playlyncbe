class Admins::SuggestionsController < Admins::BaseController
  def index
    @new_courses = Course.pending
    @approved_courses = Course.approved
    @declined_courses = Course.declined
    @issues = Issue.all
  end
end