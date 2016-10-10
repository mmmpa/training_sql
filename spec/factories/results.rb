# == Schema Information
#
# Table name: results
#
#  id         :integer          not null, primary key
#  student_id :integer
#  name       :string
#  point      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_results_on_student_id  (student_id)
#
# Foreign Keys
#
#  fk_rails_6cc04affd2  (student_id => students.id)
#

FactoryGirl.define do
  factory :result do
    student nil
    name "MyString"
    point 1
  end
end
