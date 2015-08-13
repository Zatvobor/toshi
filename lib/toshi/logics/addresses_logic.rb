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
  end
end
