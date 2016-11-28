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

    def find_confirmed_or_unconfirmed(hash)
      tx = (hash.bytesize == 64 && Toshi::Models::Transaction.where(hsh: hash).first)
      tx ||= (hash.bytesize == 64 && Toshi::Models::UnconfirmedTransaction.where(hsh: hash).first)
      tx ||= nil #converts `false` into `nil` (it's useful for `#compact`)
    end
  end
end
