module Toshi
  module PeriodsLogic
    extend self

    def current_period(year, month, mday)
      month, mday = stringify(month), stringify(mday)
      DateTime.parse("#{year}#{month}#{mday}")
    end

    def stringify(month_or_mday)
      if (month_or_mday.is_a?(Integer) || month_or_mday.is_a?(String) && month_or_mday.size == 1) && month_or_mday.to_i <= 9
        "0#{month_or_mday}"
      else
        month_or_mday
      end
    end

    def next_period(from_date, to_year_month_mday)
      year, month, mday = to_year_month_mday

      method = :next_day   if mday
      method = :next_month if (!method && month)
      method = :next_year  if (!method && year)

      shift_period(from_date, method, 1)
    end

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
