class StudentsController < ApplicationController
  def show
    @student = student
  end

  def index
    @students = Student.where(id: Student.ids.shuffle[0..1000])
  end

  def create
    Student.limit(50000).map{|s| s.id}
    redirect_to students_path
  end

  private

  def student
    Student.find(params[:student_id])
  end
end
