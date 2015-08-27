require "toshi/web/base"

module Toshi
  module Web

    class Api < Toshi::Web::Base
      # Allow cross-origin requests
      before do
        headers 'Access-Control-Allow-Origin' => '*',
                'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
                'Access-Control-Allow-Headers' => 'Content-Type'
      end
      set :protection, false
      options '/*' do
        200
      end

      helpers do
        def format
          fmt = params[:format].to_s
          fmt = 'json' if fmt == ''
          case fmt
          when 'hex' then content_type 'text/plain'
          when 'bin' then content_type 'application/octet-stream'
          when 'json' then content_type 'application/json'
          when 'rss' then content_type 'application/rss+xml'
          end
          fmt
        end

        def json(obj)
          options = {:space => ''}
          JSON.pretty_generate(obj, options)
        end
      end

      ####
      ## /blocks
      ####

      # get collection of blocks
      get '/blocks.?:format?' do
        opts  = {offset: params[:offset], limit: params[:limit], branch: params[:branch]}
        opts  = Toshi::Utils.sanitize_options(opts)
        where = {branch: opts[:branch]} if opts[:branch]

        blocks = Toshi::BlocksLogic.all(where, opts[:limit], opts[:offset])

        case format
        when 'json'
          json blocks.map(&:to_hash)
        when 'rss'
          builder :blocks_rss
        else
          raise InvalidFormatError
        end
      end

      # get latest block or search by hash or height
      get '/blocks/:block.?:format?' do
        block = Toshi::BlocksLogic.first_by_hash_or_latest_by_time!(params[:block], params[:time])

        case format
        when 'json'; json(block.to_hash)
        when 'hex';  block.raw.payload.unpack("H*")[0]
        when 'bin';  block.raw.payload
        else raise InvalidFormatError
        end
      end

      # get block transactions
      get '/blocks/:block/transactions.?:format?' do
        block = Toshi::BlocksLogic.first_by_hash_or_latest_by_time!(params[:block], params[:time])

        case format
        when 'json'
          json(block.to_hash({show_txs: true, offset: params[:offset], limit: params[:limit]}))
        else
          raise InvalidFormatError
        end
      end

      ####
      ## /transactions
      ####

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

      get '/transactions/:hash.?:format?' do
        @tx = (params[:hash].bytesize == 64 && Toshi::Models::Transaction.where(hsh: params[:hash]).first)
        @tx ||= (params[:hash].bytesize == 64 && Toshi::Models::UnconfirmedTransaction.where(hsh: params[:hash]).first)
        raise NotFoundError unless @tx

        case format
        when 'json'; json(@tx.to_hash)
        when 'hex';  @tx.raw.payload.unpack("H*")[0]
        when 'bin';  @tx.raw.payload
        else raise InvalidFormatError
        end
      end

      ####
      ## /addresses
      ####

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

      ####
      ## /search
      ####
      get '/search/:query.?:format?' do
        # block || tx
        if params[:query].bytesize == 64
          if @block = Toshi::Models::Block.where(hsh: params[:query], branch: 0).first
            path = 'blocks'
            hash = @block.hsh
          else
            if @transaction = Toshi::Models::Transaction.where(hsh: params[:query]).first
              path = 'transactions'
              hash = @transaction.hsh
            end
          end

        # block height
        elsif /\A[0-9]+\Z/.match(params[:query])
          if @block = Toshi::Models::Block.where(height: params[:query].to_i, branch: 0).first
            path = 'blocks'
            hash = @block.hsh
          end

        # address hash
        elsif Bitcoin.valid_address?(params[:query])
          if @address = Toshi::Models::Address.where(address: params[:query]).first
            path = 'addresses'
            hash = @address.address
          end
        end

        raise NotFoundError unless (path && hash)

        case format
        when 'json'
          json({
            path: path,
            hash: hash
          })
        else
          raise InvalidFormatError
        end
      end

      ####
      ## /toshi
      ####

      get '/toshi.?:format?' do
        hash = {
          peers: {
            available: Toshi::Models::Peer.count,
            connected: Toshi::Models::Peer.connected.count,
            info: Toshi::Models::Peer.connected.map{|peer| peer.to_hash}
          },
          database: {
            size: Toshi::Utils.database_size
          },
          transactions: {
            count: Toshi::Models::Transaction.total_count,
            unconfirmed_count: Toshi::Models::UnconfirmedTransaction.total_count
          },
          blocks: {
            main_count: Toshi::Models::Block.main_branch.count(),
            side_count: Toshi::Models::Block.side_branch.count(),
            orphan_count: Toshi::Models::Block.orphan_branch.count(),
          },
          status: Toshi::Utils.status
        }

        case format
        when 'json'
          json(hash)
        else
          raise InvalidFormatError
        end
      end
    end

  end
end
