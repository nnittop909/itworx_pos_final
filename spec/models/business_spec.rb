require 'rails_helper'

describe Business do 
	describe 'validations' do 
		it { is_expected.to validate_presence_of :name }
	end 
end 