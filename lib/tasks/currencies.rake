# frozen_string_literal: true

namespace :currencies do
  desc "Populates default currencies"
  task populate: :environment do
    Rails.configuration.settings['enabled_currencies'].each do |code|
      unless Currency.by_code(code).present?
        Currency.create(code: code, is_default: code == Rails.configuration.settings['default_currency'])
      end
    end
  end

end
