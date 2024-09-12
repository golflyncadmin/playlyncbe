class CourseSerializer < ActiveModel::Serializer
  attributes :id, :course_name, :course_location, :status
end
