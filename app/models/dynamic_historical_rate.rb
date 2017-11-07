# frozen_string_literal: true

class DynamicHistoricalRate
  include Rateable

  attr_accessor :date

  def initialize(date:)
    @date = Date.parse date
  end

  class << self
    def fetch(base:, target:, dates:)
      out = []
      FixerIo.new(base: base).for_dates(dates: dates).each do |response|
        return false unless response.present? && response[:base].present?
        dh = DynamicHistoricalRate.new(date: response[:date])
        dh.rate = response[:rates][target]
        out << dh
      end
      out
    end
  end
end
