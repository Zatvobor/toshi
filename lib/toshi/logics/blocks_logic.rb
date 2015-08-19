require "toshi/web/base"

module Toshi
  module BlocksLogic
    extend self

    @block = Toshi::Models::Block
    @nfe   = Toshi::Web::Base::NotFoundError

    def first_in_range(range, order=Sequel.method(:desc))
      from_range(0..range, order).first
    end

    def from_range(range, order=Sequel.method(:desc))
      key = range.first < 500_000_000 ? :height : :time
      @block.order(order.call(key)).where(key => range)
    end

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
        time ? first_in_range(time.to_i) : @block.head
      elsif ask.to_s.size < 64 && (Integer(ask) rescue false)
        @block.where(height: ask, branch: 0).first
      else
        @block.where(hsh: ask).first
      end
    end

    def last_by_time(time)
      time = Time.now if !time || time.to_i == 0
      first_in_range(time.to_i)
    end

    def all_in_period(from, period_of)
      from          = nil if from == 'now'
      end_period    = (from ? DateTime.parse(from) : DateTime.now)

      period_of ||= '1d'
      if period_of = period_of.match(/(\d+)(D|W|M|Y)/i)
        start_period  = Toshi::PeriodsLogic.prev_period(end_period, period_of[2], period_of[1].to_i)
      end
      all_in_range(start_period, end_period)
    end

    def all_in_range(start_period, end_period)
      period = start_period.to_time.utc.to_i..end_period.to_time.utc.to_i
      from_range(period)
    end

  end
end
