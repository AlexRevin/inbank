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
    retries = {}
    arr = (@from..@to).to_a
    while arr.present?
      date = arr.shift
      next if date.saturday? || date.sunday?
      (code, resp) = for_day(date.strftime('%F'))
      if code == 200
        res << resp
      else
        retries[date] ||= 0
        arr.unshift date if (retires[date] += 1) <= 3
      end
    end
    res
  end

  def for_day(day)
    p "  day: #{day}, currency: #{@base_currency[:code]}"
    response = self.class.get("/#{day}",
                              query: {
                                base: @base_currency[:code]
                              })
    if response.code == 200
      return [200, response.parsed_response.symbolize_keys]
    else
      p "request error, code: #{code}"
      return [response.code, nil]
    end
  end
end
