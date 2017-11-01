# frozen_string_literal: true

namespace :delayed do
  desc "Fetch historical data"
  task historicals: :environment do
    FetchHistoricalsJob.perform_later
  end

  desc "Calculate prediction data"
  task predictions: :environment do
    TrainPredictionJob.perform_later
  end

end
