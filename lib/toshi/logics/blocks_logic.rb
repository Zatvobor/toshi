require "toshi/web/base"

module Toshi
  module BlocksLogic
    extend self

    def all(where, limit=nil, offset=nil)
      query = Toshi::Models::Block.order(Sequel.desc(:id))
      query = query.method(:where).call(where) if where
      query.method(:limit).call(limit).method(:offset).call(offset)
    end

    def first_by_hash_or_latest_by_time!(*a)
      block = first_by_hash_or_latest_by_time(a)
      raise Toshi::Web::Base::NotFoundError unless block
      block
    end

    def first_by_hash_or_latest_by_time(ask)
      if ask.to_s == 'latest'
        Toshi::Models::Block.head
      elsif ask.to_s.size < 64 && (Integer(ask) rescue false)
        Toshi::Models::Block.where(height: ask, branch: 0).first
      else
        Toshi::Models::Block.where(hsh: ask).first
      end
    end

  end
end
