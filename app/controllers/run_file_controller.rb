class RunFileController < ApplicationController
  def create
    uploaded_file = params[:run_file]
    if uploaded_file.present?
      run_file = RunFile.new(run_data: uploaded_file.read)
      logger.info run_file
      logger.info uploaded_file
      run_file.save!

      return redirect_to "/run_files/index", status: 201
    end

    render index
  end

  def index
    @run_files = RunFile.all
  end

  def new
    @run_file = RunFile.new
  end
end
