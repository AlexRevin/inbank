# frozen_string_literal: true

class TrainPredictionJob < ApplicationJob
  queue_as :prediction

  def perform(pairs: nil)
    currency_pairs = pairs || Rails.configuration.settings['enabled_currencies']
                                   .permutation(2).to_a
    days = Rails.configuration.settings['predict_days']
    currency_pairs.each do |pair|
      (source, target) = pair
      historicals = HistoricalRate.for(source).target(target).all
      if historicals.present?
        linear(data: historicals, days: days, currency_pair: pair)
        gradient(data: historicals, days: days, currency_pair: pair)
      end
    end
  end

  def linear(data:, days:, currency_pair:)
    p "training #{currency_pair} for #{days} days with linear"
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
    p "training #{currency_pair} for #{days} days with gradient"
    linear_regression = LinearRegression.new
    linear_regression.from_historical_array data
    linear_regression.train_gradient_descent(0.0005, 1000, true)
    Prediction.from_predictor(
      predictor: linear_regression,
      type: :gradient,
      days: days,
      currency_pair: currency_pair
    )
  end
end
