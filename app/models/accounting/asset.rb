module Accounting
  class Asset < Account
    self.normal_credit_balance = false
    def self.balance(options={})
      super(options)
    end
    def balance(options={})
      super(options)
    end
  end
end
