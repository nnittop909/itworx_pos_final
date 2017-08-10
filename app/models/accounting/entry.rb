module Accounting
  class Entry < ApplicationRecord
    include PgSearch
    pg_search_scope :search_by_name, :against => [:description]
    before_save :default_date
    belongs_to :commercial_document, :polymorphic => true
    belongs_to :recorder, class_name: 'Employee', foreign_key: 'employee_id'
    has_many :credit_amounts, :extend => AmountsExtension, :class_name => 'Accounting::CreditAmount', :inverse_of => :entry, dependent: :destroy
    has_many :debit_amounts, :extend => AmountsExtension, :class_name => 'Accounting::DebitAmount', :inverse_of => :entry, dependent: :destroy
    has_many :credit_accounts, :through => :credit_amounts, :source => :account, :class_name => 'Accounting::Account'
    has_many :debit_accounts, :through => :debit_amounts, :source => :account, :class_name => 'Accounting::Account'


    validates_presence_of :description
    validate :has_credit_amounts?
    validate :has_debit_amounts?
    validate :amounts_cancel?

    scope :created_between, lambda {|from_date, to_date| where("date >= ? AND date <= ?", from_date, to_date )}
      # Support construction using 'credits' and 'debits' keys
    accepts_nested_attributes_for :credit_amounts, :debit_amounts, allow_destroy: true
    alias_method :credits=, :credit_amounts_attributes=
    alias_method :debits=, :debit_amounts_attributes=
    # attr_accessible :credits, :debits

    # Support the deprecated .build method
    def self.entered_on(hash={})
      if hash[:from_date] && hash[:to_date]
        from_date = hash[:from_date].kind_of?(Time) ? hash[:from_date] : DateTime.parse(hash[:from_date])
        to_date = hash[:to_date].kind_of?(Time) ? hash[:to_date] : DateTime.parse(hash[:to_date])
        where('date' => from_date..to_date)
      else
        all
      end
    end

    # def self.created_between(hash={})
    #   if hash[:from_date] && hash[:to_date]
    #     from_date = hash[:from_date].kind_of?(Time) ? hash[:from_date] : DateTime.parse(hash[:from_date])
    #     to_date = hash[:to_date].kind_of?(Time) ? hash[:to_date] : DateTime.parse(hash[:to_date])
    #     where('date' => from_date..to_date)
    #   else
    #     all
    #   end
    # end
    
    def self.build(hash)
      ActiveSupport::Deprecation.warn('Plutus::Transaction.build() is deprecated (use new instead)', caller)
      new(hash)
    end

    private
      def default_date
        self.date ||= Time.zone.now
      end

      def has_credit_amounts?
        errors[:base] << "Entry must have at least one credit amount" if self.credit_amounts.blank?
      end

      def has_debit_amounts?
        errors[:base] << "Entry must have at least one debit amount" if self.debit_amounts.blank?
      end

      def amounts_cancel?
        errors[:base] << "The credit and debit amounts are not equal" if credit_amounts.balance_for_new_record != debit_amounts.balance_for_new_record
      end
  end
end
