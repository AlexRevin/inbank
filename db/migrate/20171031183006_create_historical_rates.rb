# frozen_string_literal: true

class CreateHistoricalRates < ActiveRecord::Migration[5.1]
  def change
    create_table :historical_rates do |t|
      t.integer :source_currency
      t.integer :target_currency
      t.integer :rate
      t.date    :date

      t.timestamps
    end
  end
end
