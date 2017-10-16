class RemoveRecurringFromTask < ActiveRecord::Migration[5.1]
  def change
    remove_column :tasks, :recurring, :boolean
  end
end
