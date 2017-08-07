class MergedStock < ApplicationRecord
  belongs_to :stock_to_merge, foreign_key: 'stock_id', class_name: 'Stock'
  belongs_to :stock_being_merged, foreign_key: 'merged_stock_id', class_name: 'Stock'
end
