class Member < User
  include PgSearch
  pg_search_scope :search_by_name, :against => [:full_name]

  enum member_type:[:regular, :irregular]
  has_many :entries, class_name: "Accounting::Entry", foreign_key: 'commercial_document_id'
  has_many :debit_amounts, through: :entries
  has_many :credit_amounts, through: :entries
  has_many :program_subscriptions
  has_many :programs, through: :program_subscriptions

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      member_hash = row.to_hash
      member = Member.where(id: member_hash['id'])

      if member.count == 1
        member.first.update_attributes(member_hash)
      else
        Member.create!(member_hash)
      end
    end
  end

  def to_s
    full_name
  end

end
