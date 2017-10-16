class Task < ApplicationRecord
  has_many :assignments, dependent: :destroy
  has_many :users, through: :assignments, dependent: :destroy
  accepts_nested_attributes_for :assignments

  validates :name, presence: true

  after_create :clone_task, if: :has_recurrence?

  serialize :recurrence, Hash

  def recurrence=(value)
    # byebug
    if value != "null" && RecurringSelect.is_valid_rule?(value)
      super(RecurringSelect.dirty_hash_to_rule(value).to_hash)
    else
      super(nil)
    end
  end

  # def rule
  #   IceCube::Rule.from_hash recurrence
  # end

  # def schedule(start)
  #   schedule = IceCube::Schedule.new(start)
  #   schedule.add_recurrence_rule(rule)
  #   schedule
  # end

  # def display_tasks(start)
  #   if recurrence.empty?
  #     [self]
  #   else
  #     start_date = start.beginning_of_week
  #     end_date = start.end_of_week
  #     schedule(start_date).occurrences(end_date).map do |date|
  #         Task.new(id: id, name: name, start_time: date)
  #     end
  #   end
  #   # byebug
  # end

  private
  def has_recurrence?
    self.recurrence.present?
  end

  def clone_task
    @weekday_today = Date.today.wday

    # if only one day chosen, otherwise it's an array of days: @array_of_days = self.recurrence[:validations][:day]
    @task_weekday = self.recurrence[:validations][:day][0]
    @days_delay = @task_weekday - @weekday_today

    @days_array = self.recurrence[:validations][:day]

    # daily task / task every n days
    if self.recurrence[:rule_type] == "IceCube::DailyRule"
      CloneJob.set(wait: (self.recurrence[:interval]).days).perform_later(self.id)

    # weekly task
    elsif self.recurrence[:rule_type] == "IceCube::WeeklyRule"
      # if certain day of week present // logic needs to be changed to accomodate several days of week (.each?)
      # if @task_weekday.present? && (@days_delay != 0)
      #   CloneJob.set(wait: (@task_weekday - @weekday_today).days).perform_later(self.id)


      # multiple weekdays
      if @days_array.present?
        @days_array.each do |day|
          CloneJob.set(wait: (day - @weekday_today).minutes).perform_later(self.id)
        end


      # no specific weekday
      else
        CloneJob.set(wait: (self.recurrence[:interval]).weeks).perform_later(self.id)
      end

    end
  end
end

















