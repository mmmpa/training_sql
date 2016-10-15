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
#  birth_day  :datetime
#

class Student < ApplicationRecord
  has_many :results, inverse_of: :student
  has_many :friend_ships, foreign_key: :owner_id
  has_many :friends, through: :friend_ships, source: :ownee

  attr_accessor :category_grades

  scope :with_results, -> {
    eager_load(:results)
  }

  scope :birth_months, -> {
    select(%q{to_char(birth_day, 'YYYY-MM') as birth_month, sum(1) as birth_counter})
      .from("(#{select('students.*').limit(1000).to_sql}) students")
  }

  scope :birth_months2, -> {
    select(%q{to_char(birth_day, 'YYYY-MM') as birth_month})
  }

  scope :month_birth, -> (m) {
    where(mm: m)
      .from(%Q{
       (#{select(%q{*, to_char(birth_day, 'MM') as mm}).to_sql}) students
      })
  }

  scope :year_birth, -> (y) {
    where(yyyy: y)
      .from(%Q{
       (#{select(%q{*, to_char(birth_day, 'YYYY') as yyyy}).to_sql}) students
      })
  }

  scope :year_birth2, -> (y) {
    where(%Q{to_date('#{y}-01-01', 'YYYY-MM-DD') <= birth_day AND birth_day <= to_date('#{y}-12-31', 'YYYY-MM-DD')})
  }

  scope :year_birth3, -> (y) {
    where(%Q{to_char(birth_day, 'YYYY') = ? }, y.to_s)
  }


  scope :year_birth4, -> (y) {
    where(%Q{yyyy = ? }, y.to_s)
      .from(%Q{
       (#{select(%q{*, to_char(birth_day, 'YYYY') as yyyy}).to_sql}) students
      })
  }

  scope :born_in_year, -> (year) {
    where(%q{ birth_day >= ? AND birth_day < ? }, Date.new(year, 1, 1), Date.new(year + 1, 1, 1))
  }

  scope :born_in_year2, -> (year) {
    where(%q{ to_char(birth_day, 'YYYY') = ? }, year.to_s)
  }

  scope :total_score, -> (min) {
    joins(:results)
      .where(%q{ results.point >= ?}, min)
  }

  scope :has_friend_in_year, ->(year) {
    joins(:friends)
    .where(%q{ friends_students.birth_day >= ? AND friends_students.birth_day < ? }, Date.new(year, 1, 1), Date.new(year + 1, 1, 1))
    .distinct
  }

  def self.friend_test
    # ActiveRecord::Base.logger = nil
    a = 0
    b = 0
    100.times do |n|
      year = rand(1999..2016)
      a += Benchmark.realtime { where(id: has_friend_in_year(year).select(:id)).born_in_year(year).count }
      b += Benchmark.realtime { where(id: has_friend_in_year(year).pluck(:id)).born_in_year(year).count }
    end
    p [a / 100, b / 100]
  end

  def self.bench_year
    a = 0
    b = 0
    100.times do |n|
      year = rand(1999..2016)
      a += Benchmark.realtime { born_in_year(year).to_a }
      b += Benchmark.realtime { born_in_year2(year).to_a }
    end
    p [a / 100, b / 100]
  end

  def self.birth_month1
    p limit(1000).select(%q{to_char(birth_day, 'YYYY-MM') as birth_month}).order('birth_month').group('birth_month').to_a.size
    p limit(1000).birth_months.group('birth_month').to_a.size
    p limit(1000).select(%q{to_char(birth_day, 'YYYY-MM') as birth_month}).order('birth_month').group('birth_month').map(&:birth_month)
    p limit(1000).birth_months2.group_by { |s| s.birth_month }.map { |k, v| k }
    p limit(1000).birth_months2.group_by { |s| s.birth_month }.size
    p limit(1000).birth_months2.group_by { |s| s.birth_month }.map { |k, v| v.size }
    p :last
    p limit(1000).birth_months.group('birth_month').map(&:birth_counter)
  end

  def self.birth_months_list
    birth_months2.distinct.order('birth_month').map(&:birth_month)
  end

  def self.in_month
    month_birth(11).to_a.size
  end

  def self.in_year
    year_birth(rand(2009..2015)).to_a.size
  end

  def self.in_year2
    year_birth2(rand(2009..2015)).to_a.size
  end

  def self.in_year3
    year_birth3(rand(2009..2015)).to_a.size
  end

  def self.in_year4
    year_birth4(rand(2009..2015)).to_a.size
  end

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
