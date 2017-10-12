class Task < ApplicationRecord
  has_many :assignments
  has_many :users, through: :assignments
  accepts_nested_attributes_for :assignments
end
