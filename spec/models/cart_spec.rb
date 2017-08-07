require 'rails_helper'

RSpec.describe Cart, :type => :model do
	describe 'associations' do 
		it { is_expected.to belong_to :employee }
		it { is_expected.to have_many :line_items }
		it { is_expected.to have_many :stocks }
	end 
	describe 'validations' do 
	end 

	it '#total_retail_price' do 
		cart = create(:cart)
		line_item_1 = create(:line_item, cart: cart, unit_price: 10, quantity: 1)
		line_item_2 = create(:line_item, cart: cart, unit_price: 10, quantity: 1)
     
    expect(cart.total_retail_price).to eql(20)
	end

	it '#total_wholesale_price' do 
		cart = create(:cart)
		stock = create(:stock, wholesale_price: 10)
		line_item_1 = create(:line_item, cart: cart, stock: stock, unit_price: 10, quantity: 1)
		line_item_2 = create(:line_item, cart: cart, stock: stock, unit_price: 10, quantity: 1)
     
    expect(cart.total_wholesale_price).to eql(20)
	end
end 