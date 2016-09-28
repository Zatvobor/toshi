module Toshi
  module Web
    class SearchApi < Api

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

    end
  end
end
