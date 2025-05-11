class RunFile < ApplicationRecord
  has_one :run, dependent: :destroy
  belongs_to :user

  validates_presence_of :run_data, message: "Run file is required"

  after_create :process_run_data

  private

  # Process run data after file is uploaded
  def process_run_data
    RunDataProcessor.process_run_file(self)
  end
end
