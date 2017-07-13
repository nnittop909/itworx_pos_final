class Member < User
  include PgSearch
  pg_search_scope :search_by_name, :against => [:full_name]

  enum member_type:[:regular, :irregular]
  has_many :entries, class_name: "Accounting::Entry", foreign_key: 'commercial_document_id'
  has_many :debit_amounts, through: :entries
  has_many :credit_amounts, through: :entries
  has_many :program_subscriptions
  has_many :programs, through: :program_subscriptions

  def to_s
    full_name
  end

  
end
