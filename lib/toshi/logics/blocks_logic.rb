require "toshi/web/base"

module Toshi
  module BlocksLogic
    extend self

    @block = Toshi::Models::Block
    @nfe   = Toshi::Web::Base::NotFoundError

    def all(where, limit=nil, offset=nil)
      query = @block.order(Sequel.desc(:id))
      query = query.method(:where).call(where) if where
      query.method(:limit).call(limit).method(:offset).call(offset)
    end

    def first_by_hash_or_latest_by_time!(*a)
      block = first_by_hash_or_latest_by_time(*a)
      raise @nfe unless block
      block
    end

    def first_by_hash_or_latest_by_time(ask, time=nil)
      if ask.to_s == 'latest'
        time ? @block.from_time(time.to_i) : @block.head
      elsif ask.to_s.size < 64 && (Integer(ask) rescue false)
        @block.where(height: ask, branch: 0).first
      else
        @block.where(hsh: ask).first
      end
    end

    def last_by_time(time)
      time = Time.now if !time || time.to_i == 0
      @block.from_time(time.to_i)
    end

    def all_in_period(year, month, mday)
      now = DateTime.now
      if year && period_of = year.match(/(\d+)(D|W|M|Y)/i)
        end_period    = Toshi::PeriodsLogic.current_period(now.year, now.month, now.mday)
        start_period  = Toshi::PeriodsLogic.prev_period(end_period, period_of[2], period_of[1].to_i)
      else
        start_period = Toshi::PeriodsLogic.current_period(year || now.year, month || 1, mday || 1)
        end_period   = Toshi::PeriodsLogic.next_period(start_period, [year || start_period.year, month, mday])
      end
      all_in_range(start_period, end_period)
    end

    def all_in_range(start_period, end_period)
      period = start_period.to_time.utc.to_i..end_period.to_time.utc.to_i
      @block.from_range(period)
    end

  end
end
