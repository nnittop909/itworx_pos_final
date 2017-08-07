require 'rails_helper'

describe Category do 
	describe 'validations' do 
		it { is_expected.to validate_presence_of :name }
		it { is_expected.to validate_uniqueness_of :name }
	end 
	describe 'associations' do 
		it { is_expected.to have_many :products }
	end 
end 