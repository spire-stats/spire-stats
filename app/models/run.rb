class Run < ApplicationRecord
  belongs_to :users
  belongs_to :run_files
end
