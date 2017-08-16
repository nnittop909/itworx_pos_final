class Address < ApplicationRecord
  belongs_to :user
  belongs_to :customer
  
  validates :municipality, :province, presence: true
  def to_s
  	details
  end

  def details
  	if self.street.present? && self.barangay.present?
    	"#{street}, #{barangay}, #{municipality}, #{province}"
    elsif self.street.blank? && self.barangay.present?
    	"#{barangay}, #{municipality}, #{province}"
    elsif self.street.blank? && self.barangay.blank?
    	"#{municipality}, #{province}"
    end
  end
end
