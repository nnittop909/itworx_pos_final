class Member < User
  include PgSearch
  pg_search_scope :search_by_name, :against => [:full_name]

  enum member_type:[:regular, :irregular]
  has_many :entries, class_name: "Accounting::Entry", foreign_key: 'commercial_document_id'
  has_many :debit_amounts, through: :entries
  has_many :credit_amounts, through: :entries
  has_many :program_subscriptions
  has_many :programs, through: :program_subscriptions
  before_save :generate_email_password

  # def self.import(file)
  #   CSV.foreach(file.path, headers: true) do |row|
  #     member_hash = row.to_hash
  #     member = Member.where(id: member_hash['id'])

  #     if member.count == 1
  #       member.first.update_attributes(member_hash)
  #     else
  #       Member.create!(member_hash)
  #     end
  #   end
  # end

  def self.to_csv(options = {})
    desired_columns = ["id", "first_name", "last_name", "role"]
    CSV.generate(options) do |csv|
      csv << desired_columns
      all.each do |product|
        csv << member.attributes.values_at(*desired_columns)
      end
    end
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

  def generate_email_password
    self.email = "#{self.first_name.lowercase}"+"#{self.last_name.lowercase}"+"@hojap.com"
    self.password = "#{self.first_name.lowercase}"+"#{self.last_name.lowercase}"+"@hojap.com"
    self.password_confirmation = "#{self.first_name.lowercase}"+"#{self.last_name.lowercase}"+"@hojap.com"
  end

  def to_s
    full_name
  end

end
