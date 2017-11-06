class CreateIndicies < ActiveRecord::Migration[5.1]
  def change
    add_index :historical_rates, :date
    add_index :historical_rates, [:source_currency, :target_currency]

    add_index :predictions, :date
    add_index :predictions, [:source_currency, :target_currency]
    add_index :predictions, :algo

  end

end
