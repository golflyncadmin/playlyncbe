class Admins::CoursesController < Admins::BaseController
  before_action :find_course, except: [:index]
  def index
    @courses = if params[:search].present?
                 Course.search_by_name_and_user_phone(params[:search])
               else
                 case params[:filter]
                 when "frequently"
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
    @courses = @courses.paginate(page: params[:page], per_page: 10)
  end

  def approve
    @course.update(status: "approved")
    redirect_to admins_suggestions_path, notice: 'Suggestion approved successfully.'
  end

  def reject
    @course.update(status: "declined")
    redirect_to admins_suggestions_path, alert: 'Suggestion rejected successfully.'
  end

  def destroy
    if @course
      @course.destroy
      redirect_to admins_suggestions_path, alert: 'Suggestion deleted successfully.'
    else
      redirect_to admins_suggestions_path, alert: 'Something went wrong.'
    end
  end

  private

  def find_course
    @course = Course.find(params[:id])
  end

end
