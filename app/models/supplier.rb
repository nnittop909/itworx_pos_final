class Supplier < ApplicationRecord

  include PgSearch
  pg_search_scope :search_by_name, :against => [:business_name, :owner]

	has_many :stocks, dependent: :destroy
  has_many :stock_transfers
  scope :by_total_credit, -> {with_credits.to_a.sort_by(&:total_credit).reverse }
	validates :business_name, :owner, presence: true
  def to_s 
    owner || business_name
  end
	def self.with_credits
    all.select{|a| a.total_remaining_balance > 0.0 }
  end
	def total_credit
    Accounting::Account.find_by_name('Accounts Payable-Trade').credit_entries.where(commercial_document_id: self.id).map{|a| a.credit_amounts.where(account_id: Accounting::Account.find_by_name('Accounts Payable-Trade').id).pluck(:amount).sum}.sum
    # Accounting::Account.find_by_name("Accounts Payable-Trade").credit_entries.where(:commercial_document_id => self.id).map{|a| a.credit_amounts.pluck(:amount).sum}.sum
  end
  def total_payment
    Accounting::Account.find_by_name('Accounts Payable-Trade').debit_entries.where(commercial_document_id: self.id).map{|a| a.debit_amounts.where(account_id: Accounting::Account.find_by_name('Accounts Payable-Trade').id).pluck(:amount).sum}.sum
      # Accounting::Account.find_by_name("Accounts Payable-Trade").debit_entries.where(:commercial_document_id => self.id).map{|a| a.credit_amounts.pluck(:amount).sum}.sum
  end 
  def credit_payments 
    Accounting::Account.find_by_name('Accounts Payable-Trade').debit_entries.where(commercial_document_id: self.id)
  end

  def total_remaining_balance 
    total_credit - total_payment
  end
  def self.total_remaining_balance
    all.map{|a| a.total_remaining_balance }.sum
  end
  def has_credit?

  	total_remaining_balance > 0
  end
end
