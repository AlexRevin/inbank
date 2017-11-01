# frozen_string_literal: true

class CreateCurrencies < ActiveRecord::Migration[5.1]
  def change
    create_table :currencies do |t|
      t.string :code
      t.boolean :enabled, default: true
      t.boolean :is_default, default: false
      t.timestamps
    end
  end
end
