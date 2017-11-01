# frozen_string_literal: true

module CurrencyFilterable
  extend ActiveSupport::Concern
  included do
    belongs_to :source_currency, foreign_key: 'source_currency', class_name: 'Currency'
    belongs_to :target_currency, foreign_key: 'target_currency', class_name: 'Currency'

  end
end