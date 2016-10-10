class CreateResults < ActiveRecord::Migration[5.0]
  def change
    create_table :results do |t|
      t.references :student, foreign_key: true
      t.string :name
      t.integer :point

      t.timestamps
    end
  end
end
