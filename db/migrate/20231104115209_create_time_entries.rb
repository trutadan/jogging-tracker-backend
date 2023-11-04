class CreateTimeEntries < ActiveRecord::Migration[7.1]
  def change
    create_table :time_entries do |t|
      t.date :date
      t.float :distance
      t.integer :hours
      t.integer :minutes
      t.integer :seconds
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
