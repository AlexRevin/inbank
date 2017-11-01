class CreatePredictions < ActiveRecord::Migration[5.1]
  def change
    create_table :predictions do |t|
      t.integer :source_currency
      t.integer :target_currency
      t.integer :rate
      t.date :date
      t.integer :algo

      t.timestamps
    end
  end
end
