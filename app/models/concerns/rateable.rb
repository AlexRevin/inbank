# frozen_string_literal: true

module Rateable
  extend ActiveSupport::Concern
  def rate
    if respond_to?(:read_attribute)
      read_attribute(:rate) / 100_000_000.to_f
    else
      self[:rate] / 100_000_000.to_f
    end
  end

  def [](key)
    case key
    when :date
      @date
    when :rate
      @rate
    end
  end

  def rate=(val)
    if respond_to?(:write_attribute)
      write_attribute(:rate, val * 100_000_000)
    else
      @rate = val * 100_000_000
    end
  end

  def to_pure(multiplied)
    multiplied / 100_000_000.to_f
  end
end
