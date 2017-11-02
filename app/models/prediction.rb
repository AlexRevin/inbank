# frozen_string_literal: true

class Prediction < CurrencyBase
  include CurrencyFilterable
  include DateFilterable
  enum algo: %w[linear gradient]

  scope :with_algo, ->(algo) { where(algo: algo) }

  def self.for(code)
    joins('left join currencies source_currencies on predictions.source_currency = source_currencies.id')
      .where('source_currencies.code = ?', code)
  end

  def self.target(code)
    joins('left join currencies target_currencies on predictions.target_currency = target_currencies.id')
      .where('target_currencies.code = ?', code)
  end

  def self.from_predictor(predictor:, type:, days:, currency_pair:)
    future_date = Date.today + days.days
    (source, target) = [
      Currency.by_code(currency_pair[0]).last,
      Currency.by_code(currency_pair[1]).last
    ]

    (Date.today..future_date).each do |date|
      rate = predictor.predict(date: date) / 100_000_000.to_f
      existing = Prediction.with_algo(type).on(date).where(source_currency: source, target_currency: target).last
      if existing.present?
        existing.update_attributes(rate: rate) if existing[:rate] != rate
      else
        Prediction.create(
          source_currency: source,
          target_currency: target,
          algo: type,
          rate: rate,
          date: date
        )
      end
    end
  end
end
