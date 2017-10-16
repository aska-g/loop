class AddHighPriorityToTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :high_priority, :boolean, default: false
  end
end
