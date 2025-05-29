class RunFile < ApplicationRecord
  has_one :run, dependent: :destroy
  belongs_to :user

  validates_presence_of :run_data, message: "Run file is required"
end
