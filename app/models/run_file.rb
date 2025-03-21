class RunFile < ApplicationRecord
  validates_presence_of :run_data, message: "Run file is required"
end
