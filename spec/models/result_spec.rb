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

require 'rails_helper'

RSpec.describe Result, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
