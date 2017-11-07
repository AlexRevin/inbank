# frozen_string_literal: true

class DynamicCalculatorsController < CalculatorsController
  before_action :authenticate_user!
  before_action :load_currencies
  before_action :load_base_target_currencies

  def create
    @historicals = DynamicHistoricalRate.fetch(
      base: @base[:code],
      target: @target[:code],
      dates: historical_dates(params[:weeks])
    )

    @predictions = DynamicPrediction.train(
      historicals: @historicals,
      dates: prediction_dates(params[:weeks]),
      algo: params[:algo].intern,
      base: @base[:code],
      target: @target[:code]
    )

    @result = weekly_result @predictions
    @historical_result = weekly_historicals @historicals
    render :index
  end

  private

  def secure_params
    params.permit(:source, :target, :amount, :weeks, :algo)
  end

  def load_base_target_currencies
    @base = if params[:source].present?
              Currency.find(params[:source])
            else
              @currencies[0]
            end

    @target = if params[:target].present? 
                Currency.find(params[:target])
              else
                @currencies[1]
              end
  end
end
