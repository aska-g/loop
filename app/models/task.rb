class Task < ApplicationRecord
  has_many :assignments, dependent: :destroy, inverse_of: :task
  has_many :users, through: :assignments, dependent: :destroy
  accepts_nested_attributes_for :assignments

  validates :name, presence: { message: "Seems like you forgot to write down your task" }

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

  private

  def has_recurrence?
    self.recurrence.present?
  end

  def clone_task
    @weekday_today = Date.today.wday
    @week_days_array = self.recurrence[:validations][:day]

    @day_today = Date.today.day
    @month_today = Date.today.mon
    @month_days_array = self.recurrence[:validations][:day_of_month]

    @month_week_days_hash = self.recurrence[:validations][:day_of_week]

    @year_today = Date.today.year


    @interval = self.recurrence[:interval]

    # daily task / task every n days
    if self.recurrence[:rule_type] == "IceCube::DailyRule"
      CloneJob.set(wait: @interval.days).perform_later(self.id)

    # weekly task
    elsif self.recurrence[:rule_type] == "IceCube::WeeklyRule"
      # multiple weekdays
      if  @week_days_array.present?
        @week_days_array.each do |day|
          # weekday hasn't passed yet this week
          if day > @weekday_today
            CloneJob.set(wait: (day - @weekday_today).days).perform_later(self.id)
          # weekday has alrady passed this week
          elsif day < @weekday_today
            CloneJob.set(wait: (7 - (@weekday_today - day)).days).perform_later(self.id)
          # @weekday_today == task's weekday
          else
            CloneJob.set(wait: @interval.weeks).perform_later(self.id)
          end
        end
      # no specific weekday
      else
        CloneJob.set(wait: @interval.weeks).perform_later(self.id)
      end

    # monthly task
    elsif self.recurrence[:rule_type] == "IceCube::MonthlyRule"
      # task repeating on a given day of month
      if @month_days_array.present?
        @month_days_array.each do |day|
          # if the day of month has already passed in the current month
          if day == -1 && (Date.today != (Chronic.parse('1st day next month') - 1.day))
            CloneJob.set(wait_until: (Chronic.parse('1st day next month') - 1.day)).perform_later(self.id)

          elsif day == -1 && (Date.today == (Chronic.parse('1st day next month') - 1.day))
            CloneJob.set(wait_until: (Chronic.parse('next month'))).perform_later(self.id)

          elsif day < @day_today
            CloneJob.set(wait_until: DateTime.parse("#{day}-#{@month_today + 1}-#{(Date.today + 1.month).year}")).perform_later(self.id)

          # the day of month hasn't passed yet in the current month
          elsif day > @day_today
            CloneJob.set(wait: (day - @day_today).days).perform_later(self.id)

          # task's day of month == today's day of month
          else
            CloneJob.set(wait: @interval.months).perform_later(self.id)
          end
        end
      # no specific day of month
      elsif @month_days_array.present? && !@month_week_days_hash.present?
        CloneJob.set(wait: @interval.months).perform_later(self.id)
      end

      # monthly task repeating on given days of given weeks
      if @month_week_days_hash.present?
        @month_week_days_hash.each do |k, v|
          # day of week has passed this week

          v.each do |value|
            if value == 1
              order_number = "#{value}st"
            elsif value == 2
              order_number = "#{value}nd"
            elsif value == 3
              order_number = "#{value}rd"
            else
              order_number = "#{value}th"
            end

            chronic_date = "#{order_number} #{Date::DAYNAMES[k]}"
            if Time.now < Chronic.parse("#{chronic_date} this #{Date::MONTHNAMES[@month_today]}")
              CloneJob.set(wait_until: Chronic.parse("#{chronic_date} this #{Date::MONTHNAMES[@month_today]}")).perform_later(self.id)
            elsif Time.now >= Chronic.parse("#{chronic_date} this #{Date::MONTHNAMES[@month_today]}")
              CloneJob.set(wait_until: Chronic.parse("#{chronic_date} of next month")).perform_later(self.id)
            end
          end
        end

    # annual task
      elsif self.recurrence[:rule_type] == "IceCube::YearlyRule"
        CloneJob.set(wait_until: Chronic.parse("#{@interval} year from now")).perform_later(self.id)
      end
    end
  end
end

















