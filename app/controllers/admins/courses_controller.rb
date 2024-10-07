class Admins::CoursesController < Admins::BaseController
  def index
    @courses = case params[:filter]
               when "booked"
                  Course.frequently_booked
               when "recently"
                  Course.includes(:user).recently_searched
               else
                 Course.includes(:user)
                   .select("DISTINCT ON (courses.course_name) courses.*, users.phone_number")
                   .joins(:user)
                   .order("courses.course_name ASC, courses.created_at DESC")
               end
  end
end
