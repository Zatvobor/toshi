STDOUT.sync = STDERR.sync = true

require_relative 'config/environment'

require "toshi/web/www"
require "toshi/web/api"
require "toshi/web/websocket"
require 'sidekiq/web'

use Rack::CommonLogger
use Bugsnag::Rack

app = Rack::URLMap.new(
  '/'          => Toshi::Web::WWW,
  '/api/v0'    => Toshi::Web::Application,
)

map '/sidekiq' do
  use Rack::Auth::Basic, 'Sidekiq' do |username, password|
    username == ENV['SIDEKIQ_USERNAME'] && password == ENV['SIDEKIQ_PASSWORD']
  end

  run Sidekiq::Web
end

app = Toshi::Web::WebSockets.new(app)

run app
