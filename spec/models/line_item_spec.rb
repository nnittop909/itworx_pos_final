require 'rails_helper'

RSpec.describe LineItem, type: :model do
  describe 'assocations' do 
  	it { is_expected.to belong_to :itemable }
  end
end
