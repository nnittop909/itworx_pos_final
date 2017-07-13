class Category < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :products
  before_destroy :ensure_not_referenced_by_products

  private 
  def ensure_not_referenced_by_products
     errors[:base] << "Category is referenced by products" if self.products.present?
  end
end
