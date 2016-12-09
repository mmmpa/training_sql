class AddColumnLastDateToSutudent < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :last_day, :datetime
  end
end
