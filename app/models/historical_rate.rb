# frozen_string_literal: true

class HistoricalRate < CurrencyBase
  include CurrencyFilterable
  include DateFilterable

  def self.for(code)
    joins('left join currencies source_currencies '\
          'on historical_rates.source_currency = source_currencies.id')
      .where('source_currencies.code = ?', code)
  end

  def self.target(code)
    joins('left join currencies target_currencies '\
          'on historical_rates.target_currency = target_currencies.id')
      .where('target_currencies.code = ?', code)
  end

  def self.from_client_response(response)
    return false unless response.present? && response[:base].present?
    source = Currency.by_code(response[:base]).last
    return false unless source.present?
    response[:rates].each_pair do |code, value|
      next unless Rails.configuration.settings['enabled_currencies']
                       .include?(code)
      next unless (target = Currency.by_code(code).last).present?
      next if HistoricalRate.on(response[:date]).for(response[:base])
                            .target(target[:code])
                            .present?
      HistoricalRate.create(source_currency: source,
                            target_currency: target,
                            rate: value,
                            date: Date.parse(response[:date]))
    end
  end
end
