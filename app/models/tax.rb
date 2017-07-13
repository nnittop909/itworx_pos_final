class Tax < ApplicationRecord
  enum tax_type: [:include_tax_in_item_price,
                  :add_tax_to_item_price]
  
end
