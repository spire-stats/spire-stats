class RunFileController < ApplicationController
  allow_unauthenticated_access

  def create
    uploaded_file = params[:run_file]&.dig(:run_data)
    @run_file = RunFile.new(run_data: uploaded_file&.read)

    if @run_file.save
      return redirect_to action: "index"
    end

    render :new, status: :unprocessable_entity
  end

  def index
    @run_files = RunFile.all
  end

  def new
    @run_file = RunFile.new
  end
end
