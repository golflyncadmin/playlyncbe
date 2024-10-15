class Admins::ProblemsController < Admins::BaseController
  def new_issues
    @new_issues = Issue.new_issues
  end

  def archived
    @archived_issues = Issue.archived_issues
  end
end
