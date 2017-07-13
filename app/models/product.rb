class Product < ApplicationRecord
  include PublicActivity::Common
  include PgSearch
  require 'csv'

  enum stock_status: [:available, :low_stock, :out_of_stock, :discontinued]
  pg_search_scope( :search_by_name, 
                    against: [:name_and_description, :name, :bar_code, :description],
                    using: { tsearch: { prefix: true }} )

  belongs_to :category
  belongs_to :program
  has_many :stocks, dependent: :destroy
  has_many :refunds, through: :stocks
  has_many :line_items, through: :stocks
  has_many :orders, through: :line_items
  validates :name, :stock_alert_count, :retail_price, :wholesale_price, :retail_unit, presence: true

  before_destroy :ensure_not_referenced_by_any_line_item
  before_save :set_name_description
  before_update :set_name_description

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      product_hash = row.to_hash
      product = Product.where(id: product_hash['id'])

      if product.count == 1
        product.first.update_attributes(product_hash)
      else
        Product.create!(product_hash)
      end
    end
  end

  def set_wholesale_price
    if self.conversion_quantity.present? && self.wholesale_unit.present?
      wholesale_price = self.wholesale_price / self.conversion_quantity
    else
      wholesale_price
    end
  end

  def self.by_category(category)
    all.where(category: category)
  end
  def quantity
    stocks.all.sum(:quantity)
  end

  def total_wholesale_quantity
    (quantity/self.conversion_quantity).to_i
  end

  def total_retail_quantity
    (((quantity/self.conversion_quantity).modulo(1)) * self.conversion_quantity).round
  end

  def converted_total_quantity
    if (self.conversion_quantity && self.wholesale_unit).present?
      if total_retail_quantity != 0
        if total_wholesale_quantity != 0
          "#{total_wholesale_quantity} #{self.wholesale_unit}/s" + " & " + "#{total_retail_quantity} #{self.retail_unit}"
        else
          "#{total_retail_quantity} #{self.retail_unit}"
        end
      else
        "#{total_wholesale_quantity}  #{self.wholesale_unit}/s"
      end
    else
      "#{quantity} #{self.retail_unit}"
    end
  end

  def in_stock
    stocks.sum(:quantity) - line_items.sum(:quantity)
  end

  def in_stock_wholesale_quantity
    (in_stock/self.conversion_quantity).to_i
  end

  def in_stock_retail_quantity
    (((in_stock/self.conversion_quantity).modulo(1)) * self.conversion_quantity).round
  end

  def converted_in_stock_quantity
    if (self.conversion_quantity && self.wholesale_unit).present?
      if in_stock_retail_quantity != 0
        if in_stock_wholesale_quantity != 0
          "#{in_stock_wholesale_quantity} #{self.wholesale_unit}/s" + " & " + "#{in_stock_retail_quantity} #{self.retail_unit}"
        else
          "#{in_stock_retail_quantity} #{self.retail_unit}"
        end
      else
        "#{in_stock_wholesale_quantity}  #{self.wholesale_unit}/s"
      end
    else
      "#{quantity} #{self.retail_unit}"
    end
  end

  def sold
    line_items.sum(:quantity)
  end

  def sold_wholesale_quantity
    (sold/self.conversion_quantity).to_i
  end

  def sold_retail_quantity
    (((sold/self.conversion_quantity).modulo(1)) * self.conversion_quantity).round
  end

  def converted_sold_quantity
    if (self.conversion_quantity && self.wholesale_unit).present?
      if sold_retail_quantity != 0
        if sold_wholesale_quantity != 0
          "#{sold_wholesale_quantity} #{self.wholesale_unit}/s" + " & " + "#{sold_retail_quantity} #{self.retail_unit}"
        else
          "#{sold_retail_quantity} #{self.retail_unit}"
        end
      else
        "#{sold_wholesale_quantity}  #{self.wholesale_unit}/s"
      end
    else
      "#{quantity} #{self.retail_unit}/s"
    end
  end

  def converted_wholesale_price
    if self.conversion_quantity.present?
      (wholesale_price * in_stock) / (in_stock / conversion_quantity)
    else
      wholesale_price
    end
  end

  def quantity_and_unit
    "#{quantity} #{unit_retail}"
  end

  def name_description
    "#{name} #{description}"
  end

  def set_name_description
    if description.present?
      self.name_and_description = name_description
    else
      self.name_and_description = name
    end
  end

  def out_of_stock?
    in_stock.zero? || in_stock.negative? || stocks.blank?
  end

  def low_stock?
    if stocks.present?
      quantity <= stock_alert_count && !out_of_stock?
    else
      false
    end
  end

  def any_expired?
    if stocks.present?
      stocks.expired.present?
    end
  end

  def any_expired_and_low_stock?
    any_expired? && low_stock?
  end

  def stock_alert
    if out_of_stock?
      "Out of Stock"
    elsif low_stock? && !stocks.blank? && !any_expired?
      "Low on Stock"
    elsif any_expired_and_low_stock? || any_expired?
      "#{stocks.expired.count} expired"
    end
  end

  def check_stock_status
    if !out_of_stock? && !low_stock?
      self.available!
    elsif low_stock?
      self.low_stock!
    elsif out_of_stock?
      self.out_of_stock!
    end
  end

  def set_product_as_available
    self.available!
  end

  def update_prices
    self.stocks.each do |stock|
      stock.retail_price = self.retail_price
      stock.wholesale_price = self.wholesale_price
      stock.save
    end
  end
  private
  def ensure_not_referenced_by_any_line_item
    if line_items.empty?
      return true
    else
      errors.add(:base, 'Line Items present')
      return false
    end
  end
end
