module Toshi
  module Web
    class TransactionsApi < Api

      # submit new transaction to network
      post '/transactions.?:format?' do
        begin
          json = JSON.parse(request.body.read)
          ptx = Bitcoin::P::Tx.new([json['hex']].pack("H*"))
        rescue
          return { error: 'malformed transaction' }.to_json
        end

        if Toshi::Models::RawTransaction.where(hsh: ptx.hash).first ||
            Toshi::Models::UnconfirmedRawTransaction.where(hsh: ptx.hash).first
          return { error: 'transaction already received' }.to_json
        end

        begin
          processor = Toshi::Processor.new
          processor.process_transaction(ptx, raise_error=true)
        rescue Toshi::Processor::ValidationError => ex
          return { error: ex.message }.to_json
        end

        { hash: ptx.hash }.to_json
      end

      get '/transactions/confirmed' do
        case format
        when 'json'
          options = {offset: params[:offset], limit: params[:limit]}
          Toshi::Utils.sanitize_options(options)
          transactions = Toshi::TransactionsLogic.all_confirmed(options[:limit], options[:offset])

          json(transactions.to_hash.values)
        else
          raise InvalidFormatError
        end
      end

      get '/transactions/unconfirmed' do
        case format
        when 'json'
          options = {offset: params[:offset], limit: params[:limit]}
          Toshi::Utils.sanitize_options(options)
          mempool = Toshi::Models::UnconfirmedTransaction.mempool.offset(options[:offset]).limit(options[:limit])
          mempool = Toshi::Models::UnconfirmedTransaction.to_hash_collection(mempool)
          json(mempool)
        else
          raise InvalidFormatError
        end
      end

      get '/transactions:format?' do
        raise NotFoundError unless params[:ids]
        txs = params[:ids].map do |hash|
          tx = Toshi::TransactionsLogic.find_confirmed_or_unconfirmed(hash)
          tx.to_hash if tx
        end
        case format
        when 'json';
          json(txs.compact)
        else
          raise InvalidFormatError
        end
      end

      get '/transactions/:hash.?:format?' do
        tx = Toshi::TransactionsLogic.find_confirmed_or_unconfirmed(params[:hash])
        raise NotFoundError unless tx

        case format
        when 'json'; json(tx.to_hash)
        when 'hex';  tx.raw.payload.unpack("H*")[0]
        when 'bin';  tx.raw.payload
        else raise InvalidFormatError
        end
      end
    end
  end
end
