class CloneJob < ApplicationJob
  queue_as :default

  def perform(task_id)
    puts "Cloning the task..."
      @task = Task.find(task_id).dup
      @task.done = false
      @task.save
    puts "Done!"
  end
end
