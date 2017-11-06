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

  desc "Repair historical data"
  task :repair_historicals, [:source, :target] => [:environment] do |t, args|
    from = Date.today - Rails.configuration.settings['predict_days'].days
    dates = (from..Date.today).to_a.delete_if {|date| date.sunday? || date.saturday?}.map(&:strftime)
    if args[:source].present? && args[:target].present?
      pairs = [ [args[:source], args[:target]] ]
    else
      pairs = Rails.configuration.settings['enabled_currencies']
                                 .permutation(2).to_a
    end
    pairs.each do |pair|
      next if pair[0] == pair[1]
      p "checking #{pair}"
      scope = HistoricalRate.on(dates).for(pair[0]).target(pair[1]).order("date desc")
      if scope.count < dates.length
        entries = scope.all.to_a
        diff = dates - entries.map(&:date).map(&:strftime)
        client = FixerIo.new(base: pair[0])
        diff.each do |date|
          (code, resp) = client.for_day(date)
          if (code == 200)
            HistoricalRate.from_client_response resp
          end
        end

      end
    end
  end

end
