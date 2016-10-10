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

class Result < ApplicationRecord
  belongs_to :student, inverse_of: :results

  scope :grade, -> {
    select(%q{
        *,
        case
        when point > '90' then 'A'
        when point > '70' then 'B'
        when point > '40' then 'C'
        else 'D' end
        as grade
        })
  }

  scope :grade2, -> {
    select(%q{
        *,
        case
        when point > '90' then 'A'
        when point > '70' then 'B'
        when point > '40' then 'C'
        else 'D' end
        as grade2
        })
  }
  def grade
    case
      when point > 90
        'A'
      when point > 70
        'B'
      when point > 40
        'C'
      else
        'D'
    end
  end
end
