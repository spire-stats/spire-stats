class RunFile < ApplicationRecord
  has_one :run

  validates_presence_of :run_data, message: "Run file is required"
end
