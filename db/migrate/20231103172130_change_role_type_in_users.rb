class ChangeRoleTypeInUsers < ActiveRecord::Migration[7.1]
  def up
    change_column :users, :role, :integer, using: '0'
  end

  def down
    change_column :users, :role, :string
  end
end
