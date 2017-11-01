# frozen_string_literal: true

class FetchHistoricalsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    latest = HistoricalRate.last
    settings_days = Rails.configuration.settings['predict_days']
    date = latest.present? ? latest[:date] - 1.day : Date.today - settings_days.days
    Rails.configuration.settings['enabled_currencies'].each do |code|
      p "fetching historicals for #{code}"
      client = FixerIo.new(base: code, from: date)
      client.for_range.each do |response|
        HistoricalRate.from_client_response response
      end
      combinations = (Rails.configuration.settings['enabled_currencies'] - [code]).map { |enabled| [code, enabled]}
      TrainPredictionJob.perform_later(pairs: combinations)
    end
  end
end