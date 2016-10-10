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

class Student < ApplicationRecord
  has_many :results, inverse_of: :student

  attr_accessor :category_grades

  scope :with_results, -> {
    eager_load(:results)
  }

  scope :descriptions, -> {
    joins(:results)
      .select('sum(results.point) / results.count as average')
      .select('max(results.point) as max')
      .select('min(results.point) as min')
      .group(arel_table[:id])
  }

  scope :each_grade, -> {
    joins(:results)
      .select(%q{
          students.id,
          students.name,
          results.name as kind,
          case
          when results.point > '90' then 'A'
          when results.point > '70' then 'B'
          when results.point > '40' then 'C'
          else 'D' end
          as grade
          })

  }

  scope :each_grade2, -> {
    from(%Q{("students" INNER JOIN (#{Result.grade.to_sql}) results ON "results"."student_id" = "students"."id")})
      .select(%q{
          students.id,
          students.name,
          array_agg(results.name) as category_list,
          array_agg(results.grade) as grade_list
          })
      .group(arel_table[:id])
  }

  scope :each_grade3, -> {
    joins(:results)
      .select(%q{
          students.id,
          students.name,
          array_agg(results.name) as category_list,
          array_agg(case
          when results.point > '90' then 'A'
          when results.point > '70' then 'B'
          when results.point > '40' then 'C'
          else 'D' end) as grade_list
          })
      .group(arel_table[:id])
  }

  scope :each_grade4, -> {
    from(%Q{("students" INNER JOIN (#{Result.grade2.to_sql}) results ON "results"."student_id" = "students"."id")})
      .includes(:results)
  }


  scope :grades, -> {
    from(descriptions)
      .select(%q{
        case
        when average > '90' then 'A'
        when average > '70' then 'B'
        when average > '40' then 'C'
        else 'D' end
        as grade
        })
  }

  scope :grades_direct, -> {
    joins(:results)
      .select(%q{
        case
        when sum(results.point) / results.count > '90' then 'A'
        when sum(results.point) / results.count > '70' then 'B'
        when sum(results.point) / results.count > '40' then 'C'
        else 'D' end
        as grade
        })
      .group(arel_table[:id])
  }

  scope :point_list1, -> {
    includes(:results)
  }

  scope :point_list2, -> {
    eager_load(:results)
  }

  scope :point_list3, -> {
    joins(:results)
  }

  scope :point_deploy, -> {
    select('array_agg(results.point) as point')
      .group(arel_table[:id])
  }

  def grades
    category_grades = [name, kind, grade]
  end

  def grades2
    category_grades = [name, category_list.zip(grade_list)]
  end

  def description
    [average, max, min]
  end

  def ruby_grades
    category_grades = results.map(&:grade)
  end

  class << self
    def with_grade
      each_grade.group_by { |student_with_each_category|
        student_with_each_category.id
      }.map { |_, data_with_each_category|
        base = data_with_each_category.first
        base.category_grades = data_with_each_category.inject({}) do |a, datum|
          a.merge(datum.kind => datum.grade)
        end
        base
      }
    end

    def type1
      with_results.all.map(&:ruby_grades).size
    end

    def type2
      with_grade.size
    end

    def type3
      each_grade2.map(&:grades2).size
    end

    def type4
      each_grade3.map(&:grades2).size
    end

    def type5
      each_grade4.all.each do |s|
        p s.results.map(&:grade2)
      end.size
    end

    def point1
      point_list1.map do |r|
        r.results.map(&:point)
      end
    end

    def point2
      point_list3.point_deploy
    end

    def point3
      point_list3.point_deploy
    end
  end
end
