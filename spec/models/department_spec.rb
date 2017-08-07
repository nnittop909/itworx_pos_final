require 'rails_helper'

describe Department do 
	describe 'associations' do 
		it { is_expected.to have_many :entries }
		it { is_expected.to have_many :debit_amounts }
		it { is_expected.to have_many :credit_amounts }
	end 

	it '#to_s' do 
		department = create(:department, full_name: 'Accounting Department')
		expect(department.to_s).to eql('Accounting Department')
	end
end 
