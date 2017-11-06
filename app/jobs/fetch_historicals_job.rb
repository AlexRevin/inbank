# frozen_string_literal: true

class FetchHistoricalsJob < ApplicationJob
  queue_as :default

  def perform
    settings_days = Rails.configuration.settings['predict_days']
    date = if (latest = HistoricalRate.last).present?
             latest[:date] - 1.day
           else
             Date.today - settings_days.days
           end
    Rails.configuration.settings['enabled_currencies'].each do |code|
      FixerIo.new(base: code, from: date).for_range.each do |response|
        HistoricalRate.from_client_response response
      end
      combinations =
        (Rails.configuration.settings['enabled_currencies'] - [code])
        .map { |enabled| [code, enabled] }
      TrainPredictionJob.perform_later(pairs: combinations)
    end
  end
end
