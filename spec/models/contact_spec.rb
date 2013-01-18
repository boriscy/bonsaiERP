# encoding: utf-8
# author: Boris Barroso
# email: boriscyber@gmail.com
require 'spec_helper'

describe Contact do
  let(:valid_attributes) do
    { 
      matchcode: 'Boris Barroso',  first_name: 'Boris', last_name: "Barroso",
      organisation_name: 'bonsailabs', email: 'boris@bonsailabs.com',
      address: "Los Pinos Bloque 80\nDpto. 202", phone: '2745620', 
      mobile: '70681101', tax_number: '3376951' 
    }
  end

  it { should have_many(:contact_accounts) }
  it { should have_many(:incomes) }
  it { should have_many(:expenses) }

  context 'Validations' do
    it {should validate_uniqueness_of(:matchcode) }
    it {should validate_presence_of(:matchcode) }

    it { should have_valid(:email).when('test@mail.com', 'my@example.com.bo') }
    it { should_not have_valid(:email).when('test@mail.com.1', 'my@example.com.bo.', 'hi') }

    it { should have_valid(:phone).when('121212', '2323-232-98', '43 2323 32') }
    it { should_not have_valid(:phone).when('121212-', '2323-232 ', '43 2323a 32') }
  end

  it "returns the correct methods for to_s and compleet_name" do
    c = Contact.new(valid_attributes.merge(matchcode: 'Boris B.'))

    c.to_s.should eq('Boris B.')
    c.complete_name.should eq('Boris Barroso')
    c.pdf_name.should eq(c.complete_name)
  end

  it "creates a new instance with staff false" do
    c = Contact.new
    c.should_not be_staff
  end

  it 'create a valid' do
    Contact.create!(valid_attributes)
  end
end
