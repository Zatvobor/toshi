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

  end
end
