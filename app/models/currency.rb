# frozen_string_literal: true

class Currency < ApplicationRecord
  has_many :historical_rates, foreign_key: 'source_currency'

  scope :default, -> { where(is_default: true) }
  scope :by_code, ->(code) { where(code: code) }
end
