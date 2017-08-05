class Cart < ApplicationRecord
  belongs_to :employee
  has_many :line_items, dependent: :destroy
  has_many :stocks, through: :line_items

  def total_retail_price
    self.line_items.to_a.sum { |item| item.total_retail_price }
  end

  def total_wholesale_price
    self.line_items.to_a.sum { |item| item.total_wholesale_price }
  end

  def add_line_item(line_item)
    if self.stocks.include?(line_item.stock)
      self.line_items.where(stock_id: line_item.stock.id).delete_all
      # replace with a single item
      self.line_items.create!(stock_id: line_item.stock.id, quantity: line_item.quantity, pricing_type: line_item.pricing_type, unit_price: line_item.unit_price, total_price: line_item.total_retail_price, user_id: self.employee_id)
    else
      self.line_items.create!(stock_id: line_item.stock.id, quantity: line_item.quantity, pricing_type: line_item.pricing_type, unit_price: line_item.unit_price, total_price: line_item.total_retail_price, user_id: self.employee_id)
    end
  end
end
