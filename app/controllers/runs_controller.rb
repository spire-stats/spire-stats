class RunsController < ApplicationController
  def index
    @runs = Run.order(run_at: :desc)
  end

  def show
    @run = Run.find(params[:id])
  end
end
