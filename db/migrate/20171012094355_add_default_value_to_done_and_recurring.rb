class AddDefaultValueToDoneAndRecurring < ActiveRecord::Migration[5.1]
  def up
    change_column :tasks, :done, :boolean, default: false
    change_column :tasks, :recurring, :boolean, default: false
  end

  def down
    change_column :tasks, :done, :boolean, default: nil
    change_column :tasks, :recurring, :boolean, default: nil
  end
end
