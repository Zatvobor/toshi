module Toshi
  module PeriodsLogic
    extend self

    def prev_period(from_date, method, footsteps)
      case method.upcase
      when 'M' then method = :prev_month
      when 'Y' then method = :prev_year
      when 'D' then method = :prev_day
      when 'W'
        method    =  :prev_day
        footsteps *= 7
      end

      shift_period(from_date, method, footsteps)
    end

    def shift_period(from_date, method, footsteps)
      footsteps.times.reduce(from_date) do |memo|
        memo.method(method.to_sym).call
      end
    end

  end
end
