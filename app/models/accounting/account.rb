module Accounting
  class Account < ApplicationRecord
    include PgSearch
    pg_search_scope :search_by_name, :against => [:name, :type]
    class_attribute :normal_credit_balance
    enum status: [:active, :inactive]
    # belongs_to :main_account, class_name: "Accounting::Account"
    has_many :amounts, -> { includes(:credit_amounts, :debit_amounts)}
    # has_many :sub_accounts, class_name: "Accounting::Account", foreign_key: 'main_account_id'
    has_many :credit_amounts, :extend => Accounting::AmountsExtension, :class_name => 'Accounting::CreditAmount'
    has_many :debit_amounts, :extend => Accounting::AmountsExtension, :class_name => 'Accounting::DebitAmount'
    has_many :entries, through: :amounts, source: :entry, class_name: "Accounting::Entry"
    has_many :credit_entries, :through => :credit_amounts, :source => :entry, :class_name => 'Accounting::Entry'
    has_many :debit_entries, :through => :debit_amounts, :source => :entry, :class_name => 'Accounting::Entry'

    validates :type, :name, :code, presence: true
    validates :name, :code, uniqueness: true
    def to_s
      name
    end

    def self.types
      %w(Accounting::Asset Accounting::Liability Accounting::Equity Accounting::Revenue Accounting::Expense)
    end

    def self.created_between(hash={})
      if hash[:from_date] && hash[:to_date]
        from_date = hash[:from_date].kind_of?(Time) ? hash[:from_date] : DateTime.parse(hash[:from_date])
        to_date = hash[:to_date].kind_of?(Time) ? hash[:to_date] : DateTime.parse(hash[:to_date])
        where('date' => from_date..to_date)
      else
        all
      end
    end

    def balance(options={})
      if self.class == Account
        raise(NoMethodError, "undefined method 'balance'")
      else
        if self.normal_credit_balance ^ contra
          credits_balance(options) - debits_balance(options)
        else
          debits_balance(options) - credits_balance(options)
        end
      end
    end

    def credits_balance(options={})
      credit_amounts.balance(options)
    end

    def debits_balance(options={})
      debit_amounts.balance(options)
    end

    def self.balance(options={})
      if self.new.class == Account
        raise(NoMethodError, "undefined method 'balance'")
      else
        accounts_balance = BigDecimal.new('0')
        accounts = self.all
        accounts.each do |account|
          if account.contra
            accounts_balance -= account.balance(options)
          else
            accounts_balance += account.balance(options)
          end
        end
        accounts_balance
      end
    end

    def self.trial_balance
      if self.new.class == "Accounting::Account"
        Accounting::Asset.balance - (Accounting::Liability.balance + Accounting::Equity.balance + Accounting::Revenue.balance - Accounting::Expense.balance)
      else
        raise(NoMethodError, "undefined method 'trial_balance'")
      end
    end
  end
end
