require 'rails_helper'

describe OfficialReceipt do
  describe 'associations' do 
  	it { is_expected.to belong_to :receiptable }
  end
end
