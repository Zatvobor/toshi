module Toshi
  module Web
    class AddressesApi < Api

      get '/addresses/:address.?:format?' do
        address = Toshi::AddressesLogic.first_address_or_unconfirmed_address!(address: params[:address])

        case format
        when 'json';
          json(address.to_hash)
        else
          raise InvalidFormatError
        end
      end

      get '/addresses/:address/transactions.?:format?' do
        address = Toshi::AddressesLogic.first_address_or_unconfirmed_address!(address: params[:address])

        case format
        when 'json'
          options = {show_txs: true, offset: params[:offset], limit: params[:limit], order_by: params[:order_by]}
          json address.to_hash(options)
        else
          raise InvalidFormatError
        end
      end

      get '/addresses/:address/unspent_outputs.?:format?' do
        address = Toshi::AddressesLogic.first_address!(address: params[:address])

        case format
        when 'json'
          options = {offset: params[:offset], limit: params[:limit]}
          Toshi::Utils.sanitize_options(options)

          unspent_outputs = address.unspent_outputs.offset(options[:offset])
            .limit(options[:limit]).order(:unspent_outputs__amount)

          unspent_outputs = Toshi::Models::Output.to_hash_collection(unspent_outputs)
          json(unspent_outputs)
        else
          raise InvalidFormatError
        end
      end

      get '/addresses/:address/balance_at.?:format?' do
        address   = Toshi::AddressesLogic.first_address!(address: params[:address])
        block     = Toshi::BlocksLogic.last_by_time(params[:time])
        response  = Toshi::AddressesLogic.to_balance_hash(address, block)

        case format
        when 'json'
          json(response)
        else
          raise InvalidFormatError
        end
      end

      get '/addresses/:address/balances_at.?:format?' do
        address   = Toshi::AddressesLogic.first_address!(address: params[:address])
        blocks    = Toshi::BlocksLogic.all_in_period(params[:from], params[:period_of])
        response  = blocks.map do |block|
          Toshi::AddressesLogic.to_balance_hash(address, block)
        end

        case format
        when 'json'
          json(response)
        else
          raise InvalidFormatError
        end
      end

      get '/addresses/:address/history' do
        address   = Toshi::AddressesLogic.first_address!(address: params[:address])
        blocks    = Toshi::AddressesLogic.address_ledger_entries_by_blocks(address, 300)
        response  = blocks.map do |block|
          Toshi::AddressesLogic.to_balance_hash(address, block)
        end

        case format
        when 'json'
          json(response)
        else
          raise InvalidFormatError
        end
      end

    end
  end
end
