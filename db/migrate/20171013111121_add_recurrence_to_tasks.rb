class AddRecurrenceToTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :recurrence, :text
  end
end
