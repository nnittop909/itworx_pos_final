require 'rails_helper'

describe Order do
  describe 'associations' do 
  	it { is_expected. to have_one :official_receipt_number }
  end 
end
