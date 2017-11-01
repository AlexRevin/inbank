# frozen_string_literal: true

class LinearRegression
  delegate :train_normal_equation, to: :@linear_regression
  delegate :train_gradient_descent, to: :@linear_regression
  attr_accessor :x_data, :y_data

  def initialize
    @linear_regression = RubyLinearRegression.new
    @x_data = []
    @y_data = []
  end

  def predict(date: Date.tomorrow)
    @linear_regression.predict([date.to_time.to_i])
  end

  def from_historical_array(historical_array)
    historical_array.each do |historical|
      @x_data.push([historical[:date].to_time.to_i])
      @y_data.push(historical[:rate])
    end
    @linear_regression.load_training_data(@x_data, @y_data)
  end
end
