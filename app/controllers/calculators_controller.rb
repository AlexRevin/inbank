# frozen_string_literal: true

class CalculatorsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_currencies

  def create
    @source = Currency.find(params[:source])
    @target = Currency.find(params[:target])

    @predictions = Prediction
      .for(@source[:code])
      .target(@target[:code])
      .between(Date.today, Date.today + params[:weeks].to_i.weeks)
      .with_algo(params[:algo])
      .all.to_a

    @historicals = HistoricalRate
      .for(@source[:code])
      .target(@target[:code])
      .between(Date.today - params[:weeks].to_i.weeks - 1.days, Date.today)
      .order("date desc")
      .all.to_a

    pi = 0
    ph = 0

    @result = @predictions.reduce({}) do |sum, n|
      if ((pi += 1) % 7).zero?
        sum[n.date.strftime('%F')] = (n.rate * params[:amount].to_i).round(2)
      end
      sum
    end

    @historical_result = @historicals.reduce({}) do |sum, n|
      if ((ph += 1) % 5).zero?
        sum[n.date.strftime('%F')] = (n.rate * params[:amount].to_i).round(2)
      end
      sum
    end
    render :index
  end

  def index
  end

  private
  def secure_params
    params.permit(:source, :target, :amount, :weeks, :algo)
  end

  def load_currencies
    @currencies = Currency.all.map{ |c| [c[:code], c[:id]]}
  end
end
