class CreateRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :requests do |t|
      t.references :user, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.string :location
      t.float :latitude
      t.float :longitude
      t.text :time, array: true, default: []
      t.integer :players

      t.timestamps
    end
  end
end
