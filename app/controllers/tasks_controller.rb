class TasksController < ApplicationController
  before_action :set_task, only: [:complete, :uncomplete, :show]

  def index
    @tasks = current_user.tasks
  end

  def new
    @task = Task.new
    @task.assignments.build
  end

  def show
  end

  def create
    @task = Task.new(task_params)
    @task.assignments = task_assignments
    #@assignment.save
    @task.save
    byebug
    if @task.save
      redirect_to task_path(@task)
    else
      render :new
    end

  end

  def complete
    @task.done = true
    @task.save
    redirect_to tasks_path
  end

  def uncomplete
    @task.done = false
    @task.save
    redirect_to tasks_path
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params

    params.require(:task).permit(:name, :recurring )
  end

  def task_assignments
    ids = params[:task][:assignments_attributes]["0"]["user_id"].select(&:present?)
    ids.map { |id| Assignment.new(user_id: id) }
  end
end
