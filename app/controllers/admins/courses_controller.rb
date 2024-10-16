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
                  Course.order(created_at: :desc)
                 end
               end

    @courses = @courses.paginate(page: params[:page], per_page: 10)
  end

  def approve
    @course.update(status: :admin_approved)
    redirect_to approved_admins_suggestions_path, notice: 'Suggestion approved successfully.'
  end

  def reject
    @course.update(status: :declined)
    redirect_to declined_admins_suggestions_path, alert: 'Suggestion rejected successfully.'
  end

  def destroy
    if @course
      @course.destroy
      redirect_to declined_admins_suggestions_path, alert: 'Suggestion deleted successfully.'
    else
      redirect_to new_request_admins_suggestions_path, alert: 'Something went wrong.'
    end
  end

  private

  def find_course
    @course = Course.find(params[:id])
  end

end
