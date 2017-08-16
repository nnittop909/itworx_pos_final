class MembersController < ApplicationController

  def new
    @member = Member.new
    @member.build_address
  end

  def create
    @member = Member.create(member_params)
  end

  def edit
    @member = Member.find(params[:id])
    @address = @member.address
  end

  def update
    @member = Member.find(params[:id])
    @member.update_attributes(member_params)
  end

  private
  def member_params
    params.require(:member).permit(:last_name, :first_name, :middle_name, :member_type, :mobile, :profile_photo, address_attributes:[:id, :house_number, :street, :barangay, :municipality, :province, :id ])
  end
end
