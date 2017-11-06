# frozen_string_literal: true

class CalculatorsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_currencies

  def create
    @predictions = Prediction
                   .where(source_currency: params[:source],
                          target_currency: params[:target])
                   .on(prediction_dates(params[:weeks]))
                   .with_algo(params[:algo]).all.to_a

    @historicals = HistoricalRate
                   .where(source_currency: params[:source],
                          target_currency: params[:target])
                   .on(historical_dates(params[:weeks]))
                   .order("date desc").all.to_a

    @result = weekly_result @predictions
    @historical_result = weekly_historicals @historicals
    render :index
  end

  def index; end

  private

  def prediction_dates(weeks)
    final_date = Date.today + weeks.to_i.weeks
    dates = []
    date = Date.today
    while (date += 1.week) <= final_date
      dates.push date
    end
    dates
  end

  def historical_dates(weeks)
    final_date = Date.today - weeks.to_i.weeks
    # no historicals on weekends
    if final_date.sunday? || final_date.saturday?
      final_date -= 1.day until final_date.friday?
    end
    dates = []
    date = Date.today
    while (date -= 1.week) >= final_date
      dates.push date
    end
    dates
  end

  def weekly_result(predictions)
    predictions.each_with_object({}) do |n, sum|
      sum[n.date.strftime('%F')] = (n.rate * params[:amount].to_i).round(2)
    end
  end

  def weekly_historicals(historicals)
    historicals.each_with_object({}) do |n, sum|
      sum[n.date.strftime('%F')] = (n.rate * params[:amount].to_i).round(2)
    end
  end

  def secure_params
    params.permit(:source, :target, :amount, :weeks, :algo)
  end

  def load_currencies
    @currencies = Currency.all.map { |c| [c[:code], c[:id]] }
  end
end
