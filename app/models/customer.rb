class Customer < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_name, :against => [:full_name]

  enum member_type:[:regular, :irregular]

  has_many :orders
  has_many :line_items, through: :orders
  has_many :entries, class_name: "Accounting::Entry", foreign_key: 'commercial_document_id'
  has_many :debit_amounts, through: :entries
  has_many :credit_amounts, through: :entries
  has_many :program_subscriptions
  has_many :programs, through: :program_subscriptions
  has_one :address, dependent: :destroy

  has_attached_file :profile_photo,
                    styles: { large: "120x120>",
                   medium: "70x70>",
                    thumb: "40x40>",
                    small: "30x30>",
                    x_small: "20x20>"},
                      default_url: ":style/profile_default.jpg",
                    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                    :url => "/system/:attachment/:id/:style/:filename"
  validates_attachment :profile_photo, content_type: { content_type: ["image/jpeg", "image/gif", "image/png"] }

  accepts_nested_attributes_for :address
  validates :first_name, :last_name, presence: true
  before_save :set_full_name

  delegate :details, to: :address, prefix: true, allow_nil: true

  def self.types
    %w(Member Guest Organization)
  end

  def self.import(file)
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      member = find_by(id: row["id"]) || new
      member.attributes = row.to_hash
      member.save!
    end
  end

  def to_s
    full_name
  end

  def self.has_program_subscriptions
    all.select { |c| c.program_subscriptions.present? }
  end

  def self.compute_interests
    customers = Member.with_credits
    accounts_receivables_trade = Accounting::Account.find_by(name: "Accounts Receivables Trade - Current")
    interest_income_from_credit_sales = Accounting::Account.find_by(name: "Interest Income from Credit Sales")

    customers.each do |c|
      c.line_items.each do |l|
        program = l.stock.product.program
        interest = (program.interest_rate / 100.0) * l.total_price
        InterestProgram.create(line_item_id: l.id, amount: interest)
        Accounting::Entry.create(commercial_document_id: self.customer_id, 
        commercial_document_type: self.customer.class, date: self.date, 
        description: "Interest of order ##{self.reference_number}.", 
        debit_amounts_attributes: [{amount: interest, account: accounts_receivables_trade}], 
        credit_amounts_attributes:[{amount: interest, account: interest_income_from_credit_sales}], 
        employee_id: self.employee_id)
      end
    end
  end

  def fullname
    "#{first_name} #{last_name}"
  end

  def credit_items
    line_items.select { |l| l.order.pay_type == "credit" }
  end

  def self.with_credits
    all.select{|a| a.has_credit == true }
  end
  def with_credits?
    total_remaining_balance > 0.0
  end
  def self.total_payment
    all.map{|a| a.total_payment }.sum
  end
  def self.total_credit
    all.map{|a| a.total_credit }.sum
  end

  def total_credit
    Accounting::Account.find_by_name('Accounts Receivables Trade - Current').debit_entries.where(commercial_document_id: self.id).distinct.pluck(:amount).sum
    # Accounting::Account.find_by_name("Accounts Receivables Trade - Current").entries.where(:commercial_document_id => self.id).map{|a| a.credit_amounts.pluck(:amount).sum}.sum
  end

  def total_interest
    Accounting::Account.find_by_name('Interest Income from Credit Sales').credit_entries.where(commercial_document_id: self.id).distinct.pluck(:amount).sum
  end

  def total_catering_expenses
    Accounting::Account.find_by_name('Raw Material Purchases').debit_entries.where(commercial_document_id: self.id).distinct.pluck(:amount).sum
  end

  def catering_items
    Accounting::Account.find_by_name('Raw Material Purchases').debit_entries.where(commercial_document_id: self.id).distinct.order(date: :desc) +
    Accounting::Account.find_by_name('Income from Service Operations').credit_entries.where(commercial_document_id: self.id).distinct.order(date: :desc) +
    Accounting::Account.find_by_name('Service Fees').credit_entries.where(commercial_document_id: self.id).distinct.order(date: :desc)
  end

  def catering_cost
    Accounting::Account.find_by_name('Raw Material Purchases').debit_entries.where(commercial_document_id: self.id).distinct.order(date: :desc)
  end

  def total_payment
    Accounting::Account.find_by_name('Accounts Receivables Trade - Current').credit_entries.where(commercial_document_id: self.id).distinct.pluck(:amount).sum
  end

  def credit_payments
    Accounting::Account.find_by_name('Accounts Receivables Trade - Current').credit_entries.where(commercial_document_id: self.id).distinct
  end
  
  def total_remaining_balance
    total_credit_transactions - total_payment
  end
  def total_cash_transactions
    orders.cash.map{|a| a.total_amount_less_discount}.sum
  end
  def total_credit_transactions
    total_credit + total_catering_expenses
  end
  def total_discount 
    orders.map{|a| a.discount.amount}.sum
  end
  def self.total_remaining_balance
    all.map{|a| a.total_remaining_balance }.sum
  end

  def first_credit_created_at
    if line_items.credit.present?
      line_items.first.created_at
    end
  end

  def set_has_credit_to_false!
    if total_remaining_balance == 0.0
      self.update(has_credit: false)
    end
  end

  private
  def set_full_name
    self.full_name = fullname
  end

end
