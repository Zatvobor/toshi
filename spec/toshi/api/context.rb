require 'toshi/web/api'

RSpec.shared_context 'shared context' do
  include Rack::Test::Methods

  def app
    @app ||= Toshi::Web::Api
  end

  before do |it|
    unless it.metadata[:skip_before]
      processor = Toshi::Processor.new
      blockchain = Blockchain.new
      blockchain.load_from_json("simple_chain_1.json")
      blockchain.chain['main'].each{|height, block|
        processor.process_block(block, raise_errors=true)
      }
    end
  end
end
