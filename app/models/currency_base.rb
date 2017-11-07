# frozen_string_literal: true

class CurrencyBase < ApplicationRecord
  self.abstract_class = true
  include Rateable
end
