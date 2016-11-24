require "toshi/web/base"

module Toshi
  module Web

    class Api < Toshi::Web::Base
      # Allow cross-origin requests
      before do
        headers 'Access-Control-Allow-Origin' => '*',
                'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
                'Access-Control-Allow-Headers' => ['Content-Type', 'Accept', 'Origin']
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
      use Toshi::Web::ToshiApi
    end
  end
end
