module Toshi
  module Web
    class BlocksApi < Api

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

    end
  end
end
