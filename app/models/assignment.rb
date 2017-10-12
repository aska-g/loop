class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :task

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :task

end
