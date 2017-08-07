require 'rails_helper'

describe Address do 
	context 'associations' do 
		it { is_expected.to belong_to :user }
	end 
	context 'validations' do 
		it { is_expected.to validate_presence_of :municipality }
		it { is_expected.to validate_presence_of :province }
	end

	it '#.to_s' do 
	end
	context '#details' do 
		it '#if street and barangay and municipality and province is present' do 
			address = create(:address, street: 'Poblacion West', barangay: 'Poblacion', municipality: 'Lagawe', province: 'Ifugao')

			expect(address.details).to eql( 'Poblacion West, Poblacion, Lagawe, Ifugao')
		end 
		it '#if barangay and municipality and province is present' do 
			address = create(:address, street: nil, barangay: 'Poblacion', municipality: 'Lagawe', province: 'Ifugao')

			expect(address.details).to eql( 'Poblacion, Lagawe, Ifugao')
		end 
		it '#if municipality and province is present' do 
			address = create(:address, street: nil, barangay: nil, municipality: 'Lagawe', province: 'Ifugao')

			expect(address.details).to eql( 'Lagawe, Ifugao')
		end 
	end 

end 