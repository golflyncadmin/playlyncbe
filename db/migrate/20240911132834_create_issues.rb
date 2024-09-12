class CreateIssues < ActiveRecord::Migration[7.0]
  def change
    create_table :issues do |t|
      t.string :email
      t.string :subject
      t.text :body

      t.timestamps
    end
  end
end
