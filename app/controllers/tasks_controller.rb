class TasksController < ApplicationController
  before_action :set_task, only: [:complete, :uncomplete, :show, :edit, :update, :destroy]

  def index
    if current_user.admin?
      @tasks = Task.all
    else
      @tasks = current_user.tasks.where(:created_at => Date.today.at_beginning_of_week..Date.today.at_end_of_week)
    end

    # @display_tasks = @tasks.flat_map{ |t| t.display_tasks(params.fetch(:start_date, Time.zone.now).to_date ) }
  end

  def new
    @task = Task.new
    @users = User.all
    @assignment = @task.assignments.build
  end

  def show
  end

  def create
    @task = Task.new(task_params)
    @task.assignments = task_assignments
    @task.save
    if @task.save
      redirect_to tasks_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    @task.assignments = task_assignments

    if @task.update(task_params)
      redirect_to task_path(@task)
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: 'Task was successfully destroyed.'
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
    params.require(:task).permit(:name, :recurrence, :high_priority, :due_date )
  end

  def task_assignments
    ids = params[:task]["user_ids"].reject(&:empty?)
    ids.map { |id| Assignment.new(user_id: id) }
  end
end
