# frozen_string_literal: true

class Prediction < CurrencyBase
  include CurrencyFilterable
  include DateFilterable
  enum algo: %w[linear gradient]

  scope :with_algo, ->(algo) { where(algo: algo) }

  def self.for(code)
    joins('left join currencies source_currencies '\
          'on predictions.source_currency = source_currencies.id')
      .where('source_currencies.code = ?', code)
  end

  def self.target(code)
    joins('left join currencies target_currencies '\
          'on predictions.target_currency = target_currencies.id')
      .where('target_currencies.code = ?', code)
  end

  class << self
    def from_predictor(predictor:, type:, days:, currency_pair:)
      source = Currency.by_code(currency_pair[0]).last
      target = Currency.by_code(currency_pair[1]).last

      (Date.today..Date.today + days.days).each do |date|
        rate = predictor.predict(date: date) / 100_000_000.to_f
        if (existing = Prediction
                   .where(source_currency: source, target_currency: target)
                   .on(date).with_algo(type).last).present?
          existing.update_attributes(rate: rate) if existing[:rate] != rate
        else
          Prediction.create(
            source_currency: source, target_currency: target, date: date,
            algo: type, rate: rate
          )
        end
      end
    end
  end
end
