class Api::V1::CoursesController < Api::ApiController
  before_action :authorize_request

  # Get all approved courses
  def index
    courses = Course.approved
    success_response('Courses fetched successfully', courses.map { |course| CourseSerializer.new(course) }, :ok)
  end

  # Suggest a course
  def create
    existing_course = current_user.courses.find_by(course_name: course_params[:course_name], course_location: course_params[:course_location])

    if existing_course
      error_response("You have already suggested this course at this location", :unprocessable_entity)
    else
      course = current_user.courses.new(course_params)
      course.status = :pending

      if course.save
        success_response('Course suggested successfully (pending approval)', { course: CourseSerializer.new(course) }, :created)
      else
        error_response(course.errors.full_messages.join(', '), :unprocessable_entity)
      end
    end
  end

  private

  def course_params
    params.require(:course).permit(:course_name, :course_location)
  end
end
