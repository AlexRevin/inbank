# frozen_string_literal: true

class FixerIo
  include HTTParty
  base_uri 'api.fixer.io'

  attr_accessor :from, :to
  attr_accessor :base_currency

  def initialize(base: nil, from: Date.yesterday, to: Date.today)
    @from = from
    @to = to
    @base_currency = if base.present?
      Currency.by_code(base).last
    else
      Currency.default.last
    end
  end

  def for_range
    res = []
    (@from..@to).each do |date|
      res << for_day(date.strftime('%F')).symbolize_keys
    end
    res
  end

  private

  def for_day(day)
    p "  day: #{day}"
    self.class.get("/#{day}", query: { base: @base_currency[:code] }).parsed_response
  end
end
