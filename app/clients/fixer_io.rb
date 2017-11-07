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

  def for_dates(dates:)
    res = []
    retries = {}
    while dates.present?
      date = dates.shift
      next if date.saturday? || date.sunday?
      raw = for_day(date.strftime('%F'))
      if raw.present? && raw[:code] == 200
        res << raw[:resp]
      else
        retries[date] ||= 0
        dates.unshift date if (retries[date] += 1) <= 3
      end
    end
    res
  end

  def for_range
    arr = (@from..@to).to_a
    for_dates(dates: arr)
  end

  def for_day(day)
    p "  day: #{day}, currency: #{@base_currency[:code]}"
    Rails.cache.fetch("/historicals/#{day}/#{@base_currency[:code]}",
                      expires_in: 12.hours) do
      p "    req API "
      response = self.class.get("/#{day}",
                                query: {
                                  base: @base_currency[:code]
                                })
      if response.code == 200
        {
          code: 200,
          resp: response.parsed_response.symbolize_keys
        }
      end
    end
  end
end
