class Product < ApplicationRecord
  include PublicActivity::Common
  include PgSearch
  require 'csv'

  enum stock_status: [:available, :low_stock, :out_of_stock, :discontinued]
  pg_search_scope( :search_by_name, 
                    against: [:name_and_description, :name, :description],
                    using: { tsearch: { prefix: true }} )

  belongs_to :category
  belongs_to :program
  has_many :stocks, dependent: :destroy
  has_many :refunds, through: :stocks
  has_many :line_items, through: :stocks
  has_many :orders, through: :line_items
  validates :name, :retail_price, :wholesale_price, :unit, presence: true

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

  def self.by_category(category)
    all.where(category: category)
  end
  def quantity
    stocks.purchased.sum(:quantity)
  end

  def in_stock
    if stocks.purchased.sum(:quantity) <= 0
      0
    else
      stocks.purchased.sum(:quantity) - line_items.sum(:quantity)
    end
  end

  def sold
    line_items.sum(:quantity)
  end

  def self.total_inventory_cost
    all.sum { |t| t.total_stock_cost}
  end

  def total_stock_cost
    self.stocks.sum(:total_cost)
  end

  def quantity_and_unit
    "#{quantity} #{unit}"
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

  def self.out_of_stock
    all.order(:name).select{ |a| a.out_of_stock?}
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
      self.stock_status = nil
    elsif out_of_stock?
      self.stock_status = nil
      self.save
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
