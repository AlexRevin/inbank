# frozen_string_literal: true

class DynamicPrediction
  include Rateable

  attr_accessor :date

  def initialize(date:)
    @date = date
  end

  class << self
    def trainer(historicals:, algo:, base:, target:)
      key = historicals.map(&:date).to_set.hash
      Rails.cache.fetch("/prediction/#{algo}/#{key}/#{base}/#{target}",
                        expires_in: 12.hours) do
        predictor = LinearRegression.new
        predictor.from_historical_array historicals

        case algo
        when :linear
          predictor.train_normal_equation
        when :gradient
          predictor.train_gradient_descent(0.0005, 1000, true)
        end
        predictor
      end
    end

    def train(historicals:, dates:, algo: :linear, base:, target:)
      predictor = trainer(historicals: historicals, algo: algo, 
                          base: base, target: target)
      out = []
      dates.each do |date|
        dp = DynamicPrediction.new(date: date)
        dp.rate = predictor.predict(date: date) / 100_000_000.to_f
        out << dp
      end
      out
    end
  end
end
