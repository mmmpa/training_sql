class AddColumnBirthDayToStudent < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :birth_day, :datetime
  end
end
