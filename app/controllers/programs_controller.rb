class ProgramsController < ApplicationController

  def new
    @program = Program.new
  end

  def create
    @programs = Program.all
    @program = Program.create(program_params)
  end

  def edit
    @program = Program.find(params[:id])
  end

  def update
    @program = Program.find(params[:id])
    @program.update_attributes(program_params)
  end

  def destroy
    @program = Program.find(params[:id])
    @program.destroy
  end

  private
  def program_params
    params.require(:program).permit(:name, :interest_rate, :number_of_days)
  end
end
