class TrainPredictionJob < ApplicationJob
  queue_as :default

  def perform(*args)
    currency_pairs = Rails.configuration.settings['enabled_currencies'].repeated_combination(2).to_a
    days = Rails.configuration.settings['predict_days']
    currency_pairs.each do |pair|
      (source, target) = pair
      historicals = HistoricalRate.for(source).target(target).all
      linear(data: historicals, days: days, currency_pair: pair)
      gradient(data: historicals, days: days, currency_pair: pair)
    end
  end

  def linear(data:, days:, currency_pair:)
    linear_regression = LinearRegression.new
    linear_regression.from_historical_array data
    linear_regression.train_normal_equation
    Prediction.from_predictor(
      predictor: linear_regression,
      type: :linear,
      days: days,
      currency_pair: currency_pair
    )
  end

  def gradient(data:, days:, currency_pair:)
    linear_regression = LinearRegression.new
    linear_regression.from_historical_array data
    linear_regression.train_gradient_descent(0.0005, 2000, true)
    Prediction.from_predictor(
      predictor: linear_regression,
      type: :gradient,
      days: days,
      currency_pair: currency_pair
    )
  end
end
