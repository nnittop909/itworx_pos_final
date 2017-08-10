class Department < Member
	include PgSearch
  pg_search_scope :search_by_name, :against => [:full_name]

	has_many :entries, class_name: "Accounting::Entry", as: :commercial_document
  has_many :debit_amounts, through: :entries
  has_many :credit_amounts, through: :entries

  def to_s
  	full_name
  end

  
end