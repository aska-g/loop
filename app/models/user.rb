class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :assignments, dependent: :destroy
  has_many :tasks, through: :assignments, dependent: :destroy
  accepts_nested_attributes_for :assignments
end
