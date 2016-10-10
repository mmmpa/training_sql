# == Schema Information
#
# Table name: students
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  city       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :student do
    name "MyString"
    email "MyString"
    city "MyString"
  end
end
