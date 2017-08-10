class User < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_name, :against => [:full_name, :first_name, :last_name]
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  scope :by_total_credit, -> {with_credits.to_a.sort_by(&:total_credit).reverse }
  has_one :address, dependent: :destroy
  has_many :sales, foreign_key: 'employee_id', class_name: 'Order'
  has_many :stock_tansfers, foreign_key: 'employee_id'
  has_many :refunds, foreign_key: 'employee_id'
  has_many :entries, class_name: "Accounting::Entry", foreign_key: 'commercial_document_id'

  accepts_nested_attributes_for :address
  
  enum role:[:cashier, 
            :stock_custodian, 
            :bir_officer, 
            :proprietor, 
            :bookkeeper, 
            :accountant, 
            :customer]
  
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
  validates :first_name, :last_name, :role, presence: true
  
  before_save :set_full_name
  
  delegate :details, to: :address, prefix: true, allow_nil: true
  
  def fullname
    "#{first_name} #{last_name}"
  end

  private
  def set_full_name
    self.full_name = fullname
  end
end
