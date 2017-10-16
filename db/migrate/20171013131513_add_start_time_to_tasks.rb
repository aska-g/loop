class AddStartTimeToTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :start_time, :datetime
  end
end
