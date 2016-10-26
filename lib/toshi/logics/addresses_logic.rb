require "toshi/web/base"

module Toshi
  module AddressesLogic
    extend self

    @address              = Toshi::Models::Address
    @unconfirmed_address  = Toshi::Models::UnconfirmedAddress
    @nfe                  = Toshi::Web::Base::NotFoundError

    def first_address_or_unconfirmed_address!(*where)
      address = first_address_or_unconfirmed_address(*where)
      raise @nfe unless address
      address
    end

    def first_address_or_unconfirmed_address(where)
      first_address(where) || unconfirmed_address(where)
    end

    def first_address!(*where)
      address = first_address(*where)
      raise @nfe unless address
      address
    end

    def first_address(where)
      @address.method(:where).call(where).first
    end

    def unconfirmed_address!(*where)
      address = unconfirmed_address(*where)
      raise @nfe unless address
      address
    end

    def unconfirmed_address(where)
      @unconfirmed_address.method(:where).call(where).first
    end

    def address_ledger_entries_by_blocks(address, limit=nil)
      rows = Toshi.db[:address_ledger_entries]
        .select(:transaction_id, :height)
        .where(address_id: address.id)
        .join(:transactions, :id => :transaction_id)
        .where(pool: Toshi::Models::Transaction::TIP_POOL)
        .limit(limit)
      ids = rows
        .all
        .uniq{|r| r[:transaction_id]}
        .map{|r| r[:height]}
      Toshi::Models::Block.where(height: ids)
    end

    def to_balance_hash(address, block)
      {
        balance: address.balance_at(block.height),
        address: address.address,
        block_height: block.height,
        block_time: block.time
      }
    end
  end
end
