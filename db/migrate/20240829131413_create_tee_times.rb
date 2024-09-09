class CreateTeeTimes < ActiveRecord::Migration[7.0]
  def change
    create_table :tee_times do |t|
      t.references :user, null: false, foreign_key: true
      t.references :request, null: false, foreign_key: true
      t.string :course_name
      t.string :start_time
      t.string :course_date
      t.string :booking_url
      t.string :min_price
      t.string :max_price
      t.string :max_players
      t.string :address

      t.timestamps
    end
  end
end
