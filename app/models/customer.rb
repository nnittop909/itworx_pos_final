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
    %w(Member Guest Catering)
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

  def fullname
    "#{first_name} #{last_name}"
  end

  def self.with_credits
    all.select{|a| a.with_credits? }
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

  def total_catering_expenses
    Accounting::Account.find_by_name('Raw Material Purchases').credit_entries.where(commercial_document_id: self.id).distinct.pluck(:amount).sum
  end

  def catering_expenses
    Accounting::Account.find_by_name('Raw Material Purchases').credit_entries.where(commercial_document_id: self.id).distinct
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
    orders.credit.map{|a| a.total_amount_less_discount}.sum + total_catering_expenses
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

  private
  def set_full_name
    self.full_name = fullname
  end

end
