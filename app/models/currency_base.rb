# frozen_string_literal: true

class CurrencyBase < ApplicationRecord
  self.abstract_class = true
  def rate
    self[:rate] / 1000.to_f
  end
end
