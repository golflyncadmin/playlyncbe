class Admins::CoursesController < Admins::BaseController
  def index
    @courses = Course.all
  end
end
