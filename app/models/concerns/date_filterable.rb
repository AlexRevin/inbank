# frozen_string_literal: true

module DateFilterable
  extend ActiveSupport::Concern
  included do
    scope :on, ->(date) { where(date: date) }
    scope :between, ->(start_at, end_at) {where('date > ? AND date < ?', start_at, end_at) }
  end
end
