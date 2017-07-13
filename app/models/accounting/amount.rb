module Accounting
  class Amount < ApplicationRecord
    belongs_to :account, class_name: "Accounting::Account"
    belongs_to :entry, class_name: "Accounting::Entry"

    validates :type, :amount, :entry, :account, presence: true

    def account_name=(name)
      self.account = Accounting::Account.find_by_name(name)
    end

    protected
    # Support constructing amounts with account = "name" syntax
    # def account_with_name_lookup=(v)
    #   if v.kind_of?(String)
    #     ActiveSupport::Deprecation.warn('Plutus was given an :account String (use account_name instead)', caller)
    #     self.account_name = v
    #   else
    #     self.account_without_name_lookup = v
    #   end
    # end
    # alias_method_chain :account=, :name_lookup
    
  end
end
