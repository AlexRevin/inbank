# frozen_string_literal: true

class CurrencyBase < ApplicationRecord
  self.abstract_class = true
  def rate
    self[:rate] / 100_000_000.to_f
  end

  def rate=(val)
    write_attribute(:rate, val * 100_000_000)
  end

  def to_pure(multiplied)
    multiplied / 100_000_000.to_f
  end
end
