module Toshi
  module TransactionsLogic
    extend self

    @transaction = Toshi::Models::Transaction

    def all(where, limit=nil, offset=nil)
      query = @transaction.order(Sequel.desc(:id))
      query = query.method(:where).call(where) if where
      query.method(:limit).call(limit).method(:offset).call(offset)
    end

    def all_confirmed(limit=nil, offset=nil)
      all(nil, limit, offset)
    end
  end
end
