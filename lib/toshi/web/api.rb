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
    end

    Dir.glob(File.expand_path('../api/*_api.rb', __FILE__)).each { |file| require file }
    class Application < Sinatra::Base

      use Toshi::Web::AddressesApi
      use Toshi::Web::BlocksApi
      use Toshi::Web::TransactionsApi
      use Toshi::Web::SearchApi

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
