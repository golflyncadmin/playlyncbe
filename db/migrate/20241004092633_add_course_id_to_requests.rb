class AddCourseIdToRequests < ActiveRecord::Migration[7.0]
  def change
    add_reference :requests, :course, foreign_key: true
  end
end
