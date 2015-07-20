require 'spec_helper'
require 'digest'

require 'toshi/web/api'

describe Toshi::Web::Api, :type => :request do
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

  describe "GET /blocks" do
    it "loads blocks" do
      get '/blocks'

      expect(last_response).to be_ok
      expect(json.count).to eq(8)

      expect(json[1]['hash']).to eq('000ff5c07c4fecfed17ce7af54e968656d2f568e68753100748a00ae1ed79ee9')
      expect(json[1]['branch']).to eq('main')
      expect(json[1]['previous_block_hash']).to eq('002ce1371437db4292f16a35ccaa36d1338945f72310df633cca3cf272fd17cc')
      expect(json[1]['next_blocks'][0]['hash']).to eq('0092c7814a2a32c056384b2b61f500b61c23745e279f4a01dd10cb1b55ae9b59')
      expect(json[1]['height']).to eq(6)
      expect(json[1]['confirmations']).to eq(2)
      expect(json[1]['merkle_root']).to eq('40d17ca54556e99e1dec77324f99da327c7c6fde243ab069dec1d5b5352fc768')
      expect(json[1]['time']).to eq('2014-06-07T23:39:45Z')
      expect(json[1]['nonce']).to eq(121)
      expect(json[1]['bits']).to eq(536936447)
      expect(json[1]['difficulty']).to eq(1.0e-07)
      expect(json[1]['reward']).to eq(5000000000)
      expect(json[1]['fees']).to eq(0)
      expect(json[1]['total_out']).to eq(5000000000)
      expect(json[1]['size']).to eq(250)
      expect(json[1]['transactions_count']).to eq(1)
      expect(json[1]['version']).to eq(2)
      expect(json[1]['transaction_hashes'].count).to eq(1)
    end

    it 'loads blocks with limit param' do
      get '/blocks', {limit: 1}

      expect(last_response).to be_ok
      expect(json.count).to eq(1)
    end

    it 'loads blocks with offset param' do
      get '/blocks', {limit: 1, offset: 1}

      expect(last_response).to be_ok
      expect(json.count).to eq(1)

      expect(json[0]['hash']).to eq('000ff5c07c4fecfed17ce7af54e968656d2f568e68753100748a00ae1ed79ee9')
    end
  end

  describe "GET /blocks/<hash>" do
    it "loads block" do
      get '/blocks/000ff5c07c4fecfed17ce7af54e968656d2f568e68753100748a00ae1ed79ee9'

      expect(last_response).to be_ok
      expect(json['hash']).to eq('000ff5c07c4fecfed17ce7af54e968656d2f568e68753100748a00ae1ed79ee9')
      expect(json['branch']).to eq('main')
      expect(json['previous_block_hash']).to eq('002ce1371437db4292f16a35ccaa36d1338945f72310df633cca3cf272fd17cc')
      expect(json['next_blocks'][0]['hash']).to eq('0092c7814a2a32c056384b2b61f500b61c23745e279f4a01dd10cb1b55ae9b59')
      expect(json['height']).to eq(6)
      expect(json['confirmations']).to eq(2)
      expect(json['merkle_root']).to eq('40d17ca54556e99e1dec77324f99da327c7c6fde243ab069dec1d5b5352fc768')
      expect(json['time']).to eq('2014-06-07T23:39:45Z')
      expect(json['nonce']).to eq(121)
      expect(json['bits']).to eq(536936447)
      expect(json['difficulty']).to eq(1.0e-07)
      expect(json['reward']).to eq(5000000000)
      expect(json['fees']).to eq(0)
      expect(json['total_out']).to eq(5000000000)
      expect(json['size']).to eq(250)
      expect(json['transactions_count']).to eq(1)
      expect(json['version']).to eq(2)
      expect(json['transaction_hashes'].count).to eq(1)
    end
  end

  describe "GET /blocks/<hash>/transactions" do
    it "loads block & transactions" do
      get '/blocks/000ff5c07c4fecfed17ce7af54e968656d2f568e68753100748a00ae1ed79ee9/transactions'

      expect(last_response).to be_ok

      expect(json['hash']).to eq('000ff5c07c4fecfed17ce7af54e968656d2f568e68753100748a00ae1ed79ee9')
      expect(json['branch']).to eq('main')
      expect(json['previous_block_hash']).to eq('002ce1371437db4292f16a35ccaa36d1338945f72310df633cca3cf272fd17cc')
      expect(json['next_blocks'][0]['hash']).to eq('0092c7814a2a32c056384b2b61f500b61c23745e279f4a01dd10cb1b55ae9b59')
      expect(json['height']).to eq(6)
      expect(json['confirmations']).to eq(2)
      expect(json['merkle_root']).to eq('40d17ca54556e99e1dec77324f99da327c7c6fde243ab069dec1d5b5352fc768')
      expect(json['time']).to eq('2014-06-07T23:39:45Z')
      expect(json['nonce']).to eq(121)
      expect(json['bits']).to eq(536936447)
      expect(json['difficulty']).to eq(1.0e-07)
      expect(json['reward']).to eq(5000000000)
      expect(json['fees']).to eq(0)
      expect(json['total_out']).to eq(5000000000)
      expect(json['size']).to eq(250)
      expect(json['transactions_count']).to eq(1)
      expect(json['version']).to eq(2)
      expect(json['transactions'].count).to eq(1)
    end
  end

  describe "GET /transactions/<hash>" do
    it "loads transaction" do
      get '/transactions/40d17ca54556e99e1dec77324f99da327c7c6fde243ab069dec1d5b5352fc768'

      expect(last_response).to be_ok
      expect(json['hash']).to eq('40d17ca54556e99e1dec77324f99da327c7c6fde243ab069dec1d5b5352fc768')
      expect(json['version']).to eq(1)
      expect(json['lock_time']).to eq(0)
      expect(json['size']).to eq(169)
      expect(json['inputs'][0]['previous_transaction_hash']).to eq("0000000000000000000000000000000000000000000000000000000000000000")
      expect(json['inputs'][0]['output_index']).to eq(4294967295)
      expect(json['inputs'][0]['amount']).to eq(5000000000)
      expect(json['inputs'][0]['coinbase']).to eq('01066275696c7420627920436f696e6261736520666f722072656772657373696f6e2074657374696e67')
      expect(json['outputs'][0]['amount']).to eq(5000000000)
      expect(json['outputs'][0]['spent']).to eq(false)
      expect(json['outputs'][0]['script']).to eq('04a30984dcecc38d8bb47ed1362787416bf0c39ec1afb07847d72e576f3776f3aa80570d6483c2fa09dc8b6161efd03125755752318838d2635932b1c2c43e9a14 OP_CHECKSIG')
      expect(json['outputs'][0]['script_hex']).to eq('4104a30984dcecc38d8bb47ed1362787416bf0c39ec1afb07847d72e576f3776f3aa80570d6483c2fa09dc8b6161efd03125755752318838d2635932b1c2c43e9a14ac')
      expect(json['outputs'][0]['script_type']).to eq('pubkey')
      expect(json['outputs'][0]['addresses'][0]).to eq('mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz')
      expect(json['amount']).to eq(5000000000)
      expect(json['fees']).to eq(0)
      expect(json['confirmations']).to eq(2)
      expect(json['block_height']).to eq(6)
      expect(json['block_hash']).to eq('000ff5c07c4fecfed17ce7af54e968656d2f568e68753100748a00ae1ed79ee9')
      expect(json['block_time']).to eq('2014-06-07T23:39:45Z')
      expect(json['block_branch']).to eq('main')
    end
  end

  describe "GET /addresses/<hash>" do
    it "loads address" do
      get '/addresses/mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz'

      expect(last_response).to be_ok
      expect(json['hash']).to eq('mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz')
      expect(json['balance']).to eq(5000000000)
      expect(json['received']).to eq(5000000000)
      expect(json['sent']).to eq(0)
      expect(json['unconfirmed_received']).to eq(0)
      expect(json['unconfirmed_sent']).to eq(0)
      expect(json['unconfirmed_balance']).to eq(0)
    end
  end

  describe "GET /addresses/<hash>/transactions" do
    it "loads address & transactions" do
      get '/addresses/mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz/transactions'

      expect(last_response).to be_ok
      expect(json['hash']).to eq('mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz')
      expect(json['balance']).to eq(5000000000)
      expect(json['received']).to eq(5000000000)
      expect(json['sent']).to eq(0)
      expect(json['unconfirmed_received']).to eq(0)
      expect(json['unconfirmed_sent']).to eq(0)
      expect(json['unconfirmed_balance']).to eq(0)

      expect(json['transactions'][0]['hash']).to eq('40d17ca54556e99e1dec77324f99da327c7c6fde243ab069dec1d5b5352fc768')
      expect(json['transactions'][0]['version']).to eq(1)
      expect(json['transactions'][0]['lock_time']).to eq(0)
      expect(json['transactions'][0]['size']).to eq(169)
      expect(json['transactions'][0]['inputs'][0]['previous_transaction_hash']).to eq("0000000000000000000000000000000000000000000000000000000000000000")
      expect(json['transactions'][0]['inputs'][0]['output_index']).to eq(4294967295)
      expect(json['transactions'][0]['inputs'][0]['amount']).to eq(5000000000)
      expect(json['transactions'][0]['inputs'][0]['coinbase']).to eq('01066275696c7420627920436f696e6261736520666f722072656772657373696f6e2074657374696e67')
      expect(json['transactions'][0]['outputs'][0]['amount']).to eq(5000000000)
      expect(json['transactions'][0]['outputs'][0]['spent']).to eq(false)
      expect(json['transactions'][0]['outputs'][0]['script']).to eq('04a30984dcecc38d8bb47ed1362787416bf0c39ec1afb07847d72e576f3776f3aa80570d6483c2fa09dc8b6161efd03125755752318838d2635932b1c2c43e9a14 OP_CHECKSIG')
      expect(json['transactions'][0]['outputs'][0]['script_hex']).to eq('4104a30984dcecc38d8bb47ed1362787416bf0c39ec1afb07847d72e576f3776f3aa80570d6483c2fa09dc8b6161efd03125755752318838d2635932b1c2c43e9a14ac')
      expect(json['transactions'][0]['outputs'][0]['script_type']).to eq('pubkey')
      expect(json['transactions'][0]['outputs'][0]['addresses'][0]).to eq('mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz')
      expect(json['transactions'][0]['amount']).to eq(5000000000)
      expect(json['transactions'][0]['fees']).to eq(0)
      expect(json['transactions'][0]['confirmations']).to eq(2)
      expect(json['transactions'][0]['block_height']).to eq(6)
      expect(json['transactions'][0]['block_hash']).to eq('000ff5c07c4fecfed17ce7af54e968656d2f568e68753100748a00ae1ed79ee9')
      expect(json['transactions'][0]['block_time']).to eq('2014-06-07T23:39:45Z')
      expect(json['transactions'][0]['block_branch']).to eq('main')

      expect(json['no_transactions']).to be 1
    end
  end

  describe "GET /addresses/<hash>/balance.<format>" do
    it "fails if not requesting json" do
      get '/addresses/mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz/balance_at.xml'
      expect(json['error']).to eq("Response format is not supported")
    end

    it "returns balance, target address and block info" do
      get '/addresses/mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz/balance_at.json'
      expect(json['balance']).to eq(5_000_000_000)
      expect(json['address']).to eq("mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz")
      expect(json['block_height']).to eq(7)
      expect(json['block_time']).to eq(1402184413)
    end

    it "will return a balance of 0 if there are no transactions found" do
      get '/addresses/mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz/balance_at.json?time=5'
      expect(json['balance']).to eq(0)
      expect(json['address']).to eq("mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz")
      expect(json['block_height']).to eq(5)
      expect(json['block_time']).to eq(1402184357)
    end

    it "uses block height if time is below five hundred thousand" do
      get '/addresses/mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz/balance_at.json?time=6'
      expect(json['balance']).to eq(5_000_000_000)
      expect(json['address']).to eq("mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz")
      expect(json['block_height']).to eq(6)
      expect(json['block_time']).to eq(1402184385)
    end
  end

  describe "Test filled previous output info for inputs to reorg blockchain transactions" do
    # helper used by the two test cases: check API output for 3A, 4A and 5A.
    # they're interesting because they end up on the tip after reorg.
    def check_api(blockchain)
      # block 3A
      block_3a = blockchain.chain['main']['3']
      get "/blocks/#{block_3a.hash}/transactions"
      json = JSON.parse(last_response.body)
      expect(last_response).to be_ok
      expect(json['transactions'].count).to eq(3)

      # first tx
      expect(json['transactions'][0]['inputs'].count).to eq(1)
      expect(json['transactions'][0]['outputs'].count).to eq(1)
      expect(json['transactions'][0]['inputs'][0]['coinbase']).to_not be_nil
      expect(json['transactions'][0]['inputs'][0]['amount']).to eq(50*(10**8))
      expect(json['transactions'][0]['outputs'][0]['amount']).to eq(50*(10**8))
      expect(json['transactions'][0]['outputs'][0]['addresses'].count).to eq(1)
      expect(json['transactions'][0]['outputs'][0]['addresses'].first).to eq(blockchain.address_from_label('D'))

      # second tx
      expect(json['transactions'][1]['inputs'].count).to eq(1)
      expect(json['transactions'][1]['outputs'].count).to eq(1)
      expect(json['transactions'][1]['inputs'][0]['coinbase']).to be_nil
      expect(json['transactions'][1]['inputs'][0]['amount']).to eq(40*(10**8))
      expect(json['transactions'][1]['inputs'][0]['addresses'].count).to eq(1)
      expect(json['transactions'][1]['inputs'][0]['addresses'].first).to eq(blockchain.address_from_label('B'))
      expect(json['transactions'][1]['outputs'][0]['amount']).to eq(40*(10**8))
      expect(json['transactions'][1]['outputs'][0]['addresses'].count).to eq(1)
      expect(json['transactions'][1]['outputs'][0]['addresses'].first).to eq(blockchain.address_from_label('D'))

      # third tx
      expect(json['transactions'][2]['inputs'].count).to eq(1)
      expect(json['transactions'][2]['outputs'].count).to eq(1)
      expect(json['transactions'][2]['inputs'][0]['coinbase']).to be_nil
      expect(json['transactions'][2]['inputs'][0]['amount']).to eq(10*(10**8))
      expect(json['transactions'][2]['inputs'][0]['addresses'].count).to eq(1)
      expect(json['transactions'][2]['inputs'][0]['addresses'].first).to eq(blockchain.address_from_label('C'))
      expect(json['transactions'][2]['outputs'][0]['amount']).to eq(10*(10**8))
      expect(json['transactions'][2]['outputs'][0]['addresses'].count).to eq(1)
      expect(json['transactions'][2]['outputs'][0]['addresses'].first).to eq(blockchain.address_from_label('B'))

      # block 4A
      block_4a = blockchain.chain['main']['4']
      get "/blocks/#{block_4a.hash}/transactions"
      json = JSON.parse(last_response.body)
      expect(last_response).to be_ok

      expect(json['transactions'].count).to eq(1)

      # first tx
      expect(json['transactions'][0]['inputs'].count).to eq(1)
      expect(json['transactions'][0]['outputs'].count).to eq(1)
      expect(json['transactions'][0]['inputs'][0]['coinbase']).to_not be_nil
      expect(json['transactions'][0]['inputs'][0]['amount']).to eq(50*(10**8))
      expect(json['transactions'][0]['outputs'][0]['amount']).to eq(50*(10**8))
      expect(json['transactions'][0]['outputs'][0]['addresses'].count).to eq(1)
      expect(json['transactions'][0]['outputs'][0]['addresses'].first).to eq(blockchain.address_from_label('A'))

      # block 5A
      block_5a = blockchain.chain['main']['5']
      get "/blocks/#{block_5a.hash}/transactions"
      json = JSON.parse(last_response.body)
      expect(last_response).to be_ok

      expect(json['transactions'].count).to eq(2)

      # first tx
      expect(json['transactions'][0]['inputs'].count).to eq(1)
      expect(json['transactions'][0]['outputs'].count).to eq(1)
      expect(json['transactions'][0]['inputs'][0]['coinbase']).to_not be_nil
      expect(json['transactions'][0]['inputs'][0]['amount']).to eq(50*(10**8))
      expect(json['transactions'][0]['outputs'][0]['amount']).to eq(50*(10**8))
      expect(json['transactions'][0]['outputs'][0]['addresses'].count).to eq(1)
      expect(json['transactions'][0]['outputs'][0]['addresses'].first).to eq(blockchain.address_from_label('A'))

      # second tx
      expect(json['transactions'][1]['inputs'].count).to eq(1)
      expect(json['transactions'][1]['outputs'].count).to eq(1)
      expect(json['transactions'][1]['inputs'][0]['coinbase']).to be_nil
      expect(json['transactions'][1]['inputs'][0]['amount']).to eq(50*(10**8))
      expect(json['transactions'][1]['inputs'][0]['addresses'].count).to eq(1)
      expect(json['transactions'][1]['inputs'][0]['addresses'].first).to eq(blockchain.address_from_label('B'))
      expect(json['transactions'][1]['outputs'][0]['amount']).to eq(50*(10**8))
      expect(json['transactions'][1]['outputs'][0]['addresses'].count).to eq(1)
      expect(json['transactions'][1]['outputs'][0]['addresses'].first).to eq(blockchain.address_from_label('D'))

      # check address balances and totals
      balances = { A: 150, B: 10,  C: 0,  D: 140 }
      received = { A: 150, B: 150, C: 10, D: 140 }
          sent = { A: 0,   B: 140, C: 10, D: 0   }

      address = blockchain.address_from_label('A')
      get "/addresses/#{address}"
      json = JSON.parse(last_response.body)
      expect(last_response).to be_ok
      expect(json['hash']).to eq(address)
      expect(json['balance']).to eq(balances[:A] * (10**8))
      expect(json['received']).to eq(received[:A] * (10**8))
      expect(json['sent']).to eq(sent[:A] * (10**8))

      address = blockchain.address_from_label('B')
      get "/addresses/#{address}"
      json = JSON.parse(last_response.body)
      expect(last_response).to be_ok
      expect(json['hash']).to eq(address)
      expect(json['balance']).to eq(balances[:B] * (10**8))
      expect(json['received']).to eq(received[:B] * (10**8))
      expect(json['sent']).to eq(sent[:B] * (10**8))

      address = blockchain.address_from_label('C')
      get "/addresses/#{address}"
      json = JSON.parse(last_response.body)
      expect(last_response).to be_ok
      expect(json['hash']).to eq(address)
      expect(json['balance']).to eq(balances[:C] * (10**8))
      expect(json['received']).to eq(received[:C] * (10**8))
      expect(json['sent']).to eq(sent[:C] * (10**8))

      address = blockchain.address_from_label('D')
      get "/addresses/#{address}"
      json = JSON.parse(last_response.body)
      expect(last_response).to be_ok
      expect(json['hash']).to eq(address)
      expect(json['balance']).to eq(balances[:D] * (10**8))
      expect(json['received']).to eq(received[:D] * (10**8))
      expect(json['sent']).to eq(sent[:D] * (10**8))
    end

    it "checks previous outputs for etotheipi's chain", :skip_before do
      processor = Toshi::Processor.new
      blockchain = Blockchain.new
      blockchain.load_from_json("reorg_etotheipi_chain.json")
      blockchain.blocks.each_with_index{|block,i|
        processor.process_block(block, raise_errors=true)
      }

      get '/blocks'

      expect(last_response).to be_ok
      expect(json.count).to eq(8)

      # verify the block order looks good and that they're the right blocks
      expect(json[0]['hash']).to eq(blockchain.chain['main']['5'].hash)
      expect(json[1]['hash']).to eq(blockchain.chain['main']['4'].hash)
      expect(json[2]['hash']).to eq(blockchain.chain['main']['3'].hash)
      expect(json[3]['hash']).to eq(blockchain.chain['side']['4'].hash)
      expect(json[4]['hash']).to eq(blockchain.chain['side']['3'].hash)
      expect(json[5]['hash']).to eq(blockchain.chain['main']['2'].hash)
      expect(json[6]['hash']).to eq(blockchain.chain['main']['1'].hash)
      expect(json[7]['hash']).to eq(blockchain.chain['main']['0'].hash)

      # verify the API output for the txs is what we expect
      check_api(blockchain)
    end

    it "checks previous outputs for etotheipi's chain when processed with an orphan", :skip_before do
      processor = Toshi::Processor.new
      blockchain = Blockchain.new
      blockchain.load_from_json("reorg_etotheipi_chain.json")
      missing_parent = nil
      blockchain.blocks.each_with_index{|block,i|
        if i == 2
          # don't process 2 until the very end --
          # we want the missing parent to have outputs spent by
          # a future child block. it's a more interesting test.
          missing_parent = block
          next
        end
        processor.process_block(block, raise_errors=true)
      }
      processor.process_block(missing_parent, raise_errors=true)

      get '/blocks'

      expect(last_response).to be_ok
      expect(json.count).to eq(8)

      # verify the block order looks good and that they're the right blocks
      expect(json[0]['hash']).to eq(blockchain.chain['main']['2'].hash)
      expect(json[1]['hash']).to eq(blockchain.chain['main']['5'].hash)
      expect(json[2]['hash']).to eq(blockchain.chain['main']['4'].hash)
      expect(json[3]['hash']).to eq(blockchain.chain['main']['3'].hash)
      expect(json[4]['hash']).to eq(blockchain.chain['side']['4'].hash)
      expect(json[5]['hash']).to eq(blockchain.chain['side']['3'].hash)
      expect(json[6]['hash']).to eq(blockchain.chain['main']['1'].hash)
      expect(json[7]['hash']).to eq(blockchain.chain['main']['0'].hash)

      # verify the API output for the txs is what we expect
      check_api(blockchain)
    end
  end

  describe "checks unconfirmed transaction output" do
    it 'verifies we properly handle hex and bin formats for unconfirmed transactions' do
      processor = Toshi::Processor.new
      blockchain = Blockchain.new

      # process simple chain to give us a some confirmed outputs.
      blockchain.load_from_json("simple_chain_1.json")
      blockchain.chain['main'].each{|height, block|
        processor.process_block(block, raise_errors=true)
      }

      prev_tx = blockchain.chain['main']['7'].tx[1]
      key_A = blockchain.new_key('A')
      new_tx = build_nonstandard_tx(blockchain, [prev_tx], [0], ver=Toshi::CURRENT_TX_VERSION, lock_time=nil, output_pk_script=nil, key_A)
      processor.process_transaction(new_tx, raise_errors=true)

      get "/transactions/#{new_tx.hash}.hex"
      expect(last_response).to be_ok
      expect(last_response.body).to eq(new_tx.payload.unpack("H*")[0])

      get "/transactions/#{new_tx.hash}.bin"
      expect(last_response).to be_ok
      expect(last_response.body).to eq(new_tx.payload)
    end
  end

  describe "checks unconfirmed address output" do
    it 'verifies we return info on addresses only seen in unconfirmed transactions' do
      processor = Toshi::Processor.new
      blockchain = Blockchain.new

      # process simple chain to give us a some confirmed outputs.
      blockchain.load_from_json("simple_chain_1.json")
      blockchain.chain['main'].each{|height, block|
        processor.process_block(block, raise_errors=true)
      }

      prev_tx = blockchain.chain['main']['7'].tx[1]
      key_A = blockchain.new_key('A')
      new_tx = build_nonstandard_tx(blockchain, [prev_tx], [0], ver=Toshi::CURRENT_TX_VERSION, lock_time=nil, output_pk_script=nil, key_A)
      processor.process_transaction(new_tx, raise_errors=true)

      # GET /addresses/<address>
      get "/addresses/#{blockchain.address_from_label('A')}"
      expect(last_response).to be_ok
      expect(json['hash']).to eq(blockchain.address_from_label('A'))
      expect(json['balance']).to eq(0)
      expect(json['received']).to eq(0)
      expect(json['sent']).to eq(0)
      expect(json['unconfirmed_received']).to eq((10**8) * 25)
      expect(json['unconfirmed_sent']).to eq(0)
      expect(json['unconfirmed_balance']).to eq((10**8) * 25)

      # GET /addresses/<address>/transactions
      get "/addresses/#{blockchain.address_from_label('A')}/transactions"
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json['hash']).to eq(blockchain.address_from_label('A'))
      expect(json['balance']).to eq(0)
      expect(json['received']).to eq(0)
      expect(json['sent']).to eq(0)
      expect(json['unconfirmed_received']).to eq((10**8) * 25)
      expect(json['unconfirmed_sent']).to eq(0)
      expect(json['unconfirmed_balance']).to eq((10**8) * 25)
      expect(json['unconfirmed_transactions'][0]['hash']).to eq(new_tx.hash)
      expect(json['unconfirmed_transactions'][0]['version']).to eq(new_tx.ver)
      expect(json['unconfirmed_transactions'][0]['lock_time']).to eq(0)
      expect(json['unconfirmed_transactions'][0]['size']).to eq(new_tx.payload.size)
      script = Bitcoin::Script.new(prev_tx.outputs[0].pk_script)
      expect(json['unconfirmed_transactions'][0]['inputs'][0]['previous_transaction_hash']).to eq(prev_tx.hash)
      expect(json['unconfirmed_transactions'][0]['inputs'][0]['output_index']).to eq(0)
      expect(json['unconfirmed_transactions'][0]['inputs'][0]['addresses'][0]).to eq(script.get_address)
      expect(json['unconfirmed_transactions'][0]['inputs'][0]['amount']).to eq((10**8) * 25)
      expect(json['unconfirmed_transactions'][0]['outputs'][0]['amount']).to eq((10**8) * 25)
      expect(json['unconfirmed_transactions'][0]['outputs'][0]['spent']).to eq(false)
      script = Bitcoin::Script.new(new_tx.outputs[0].pk_script)
      expect(json['unconfirmed_transactions'][0]['outputs'][0]['script']).to eq(script.to_string)
      expect(json['unconfirmed_transactions'][0]['outputs'][0]['script_hex']).to eq(new_tx.outputs[0].pk_script.unpack("H*")[0])
      expect(json['unconfirmed_transactions'][0]['outputs'][0]['script_type']).to eq(script.type.to_s)
      expect(json['unconfirmed_transactions'][0]['outputs'][0]['addresses'][0]).to eq(blockchain.address_from_label('A'))
      expect(json['unconfirmed_transactions'][0]['amount']).to eq((10**8) * 25)
      expect(json['unconfirmed_transactions'][0]['fees']).to eq(0)
      expect(json['unconfirmed_transactions'][0]['confirmations']).to eq(0)
      expect(json['unconfirmed_transactions'][0]['pool']).to eq('memory')

      key_B = blockchain.new_key('B')
      prev_tx = new_tx
      new_tx = build_nonstandard_tx(blockchain, [new_tx], [0], ver=Toshi::CURRENT_TX_VERSION, lock_time=nil, output_pk_script=nil, key_B)
      processor.process_transaction(new_tx, raise_errors=true)

      # GET /addresses/<address>/transactions
      get "/addresses/#{blockchain.address_from_label('A')}/transactions"
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json['hash']).to eq(blockchain.address_from_label('A'))
      expect(json['balance']).to eq(0)
      expect(json['received']).to eq(0)
      expect(json['sent']).to eq(0)
      expect(json['unconfirmed_received']).to eq((10**8) * 25)
      expect(json['unconfirmed_sent']).to eq((10**8) * 25)
      expect(json['unconfirmed_balance']).to eq(0)
      expect(json['unconfirmed_transactions'][0]['hash']).to eq(new_tx.hash)
      expect(json['unconfirmed_transactions'][0]['version']).to eq(new_tx.ver)
      expect(json['unconfirmed_transactions'][0]['lock_time']).to eq(0)
      expect(json['unconfirmed_transactions'][0]['size']).to eq(new_tx.payload.size)
      expect(json['unconfirmed_transactions'][0]['inputs'][0]['previous_transaction_hash']).to eq(prev_tx.hash)
      expect(json['unconfirmed_transactions'][0]['inputs'][0]['output_index']).to eq(0)
      expect(json['unconfirmed_transactions'][0]['inputs'][0]['addresses'][0]).to eq(blockchain.address_from_label('A'))
      expect(json['unconfirmed_transactions'][0]['inputs'][0]['amount']).to eq((10**8) * 25)
      expect(json['unconfirmed_transactions'][0]['outputs'][0]['amount']).to eq((10**8) * 25)
      expect(json['unconfirmed_transactions'][0]['outputs'][0]['spent']).to eq(false)
      script = Bitcoin::Script.new(new_tx.outputs[0].pk_script)
      expect(json['unconfirmed_transactions'][0]['outputs'][0]['script']).to eq(script.to_string)
      expect(json['unconfirmed_transactions'][0]['outputs'][0]['script_hex']).to eq(new_tx.outputs[0].pk_script.unpack("H*")[0])
      expect(json['unconfirmed_transactions'][0]['outputs'][0]['script_type']).to eq(script.type.to_s)
      expect(json['unconfirmed_transactions'][0]['outputs'][0]['addresses'][0]).to eq(blockchain.address_from_label('B'))
      expect(json['unconfirmed_transactions'][0]['amount']).to eq((10**8) * 25)
      expect(json['unconfirmed_transactions'][0]['fees']).to eq(0)
      expect(json['unconfirmed_transactions'][0]['confirmations']).to eq(0)
      expect(json['unconfirmed_transactions'][0]['pool']).to eq('memory')
    end
  end

  describe "checks that users can post new transactions" do
    it 'verifies basic post transactions behavior' do
      processor = Toshi::Processor.new
      blockchain = Blockchain.new

      # process simple chain to give us a some confirmed outputs.
      blockchain.load_from_json("simple_chain_1.json")
      blockchain.chain['main'].each{|height, block|
        processor.process_block(block, raise_errors=true)
      }

      prev_tx = blockchain.chain['main']['7'].tx[1]
      key_A = blockchain.new_key('A')
      new_tx = build_nonstandard_tx(blockchain, [prev_tx], [0], ver=Toshi::CURRENT_TX_VERSION, lock_time=nil, output_pk_script=nil, key_A)

      # push the tx via the API
      post "/transactions", {:hex => new_tx.payload.unpack("H*").first}.to_json
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json['hash']).to eq(new_tx.hash)

      # look for it
      get "/transactions/#{new_tx.hash}"
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json['hash']).to eq(new_tx.hash)
      expect(json['version']).to eq(1)
      expect(json['lock_time']).to eq(0)
      expect(json['size']).to eq(new_tx.payload.bytesize)
      expect(json['inputs'][0]['previous_transaction_hash']).to eq(prev_tx.hash)
      expect(json['inputs'][0]['output_index']).to eq(0)
      expect(json['inputs'][0]['amount']).to eq(2500000000)
      expect(json['outputs'][0]['amount']).to eq(2500000000)
      expect(json['outputs'][0]['spent']).to eq(false)
      script = Bitcoin::Script.new(new_tx.outputs[0].pk_script)
      expect(json['outputs'][0]['script']).to eq(script.to_string)
      expect(json['outputs'][0]['script_hex']).to eq(new_tx.outputs[0].pk_script.unpack("H*")[0])
      expect(json['outputs'][0]['script_type']).to eq('hash160')
      expect(json['outputs'][0]['addresses'][0]).to eq(blockchain.address_from_label('A'))
      expect(json['amount']).to eq(2500000000)
      expect(json['fees']).to eq(0)
      expect(json['confirmations']).to eq(0)
      expect(json['pool']).to eq('memory')

      # try pushing a double-spend
      key_B = blockchain.new_key('B')
      new_tx = build_nonstandard_tx(blockchain, [prev_tx], [0], ver=Toshi::CURRENT_TX_VERSION, lock_time=nil, output_pk_script=nil, key_B)
      post "/transactions", {:hex => new_tx.payload.unpack("H*").first}.to_json
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json['error']).to eq('AcceptToMemoryPool() : already spent in the memory pool')

      # try pushing a tx with missing inputs
      key_C = blockchain.new_key('C')
      prev_tx = new_tx
      new_tx = build_nonstandard_tx(blockchain, [prev_tx], [0], ver=Toshi::CURRENT_TX_VERSION, lock_time=nil, output_pk_script=nil, key_C)
      post "/transactions", {:hex => new_tx.payload.unpack("H*").first}.to_json
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json['error']).to eq('AcceptToMemoryPool() : transaction missing inputs')
    end

    it 'verifies resurrected orphan transactions contain an amount' do
      processor = Toshi::Processor.new
      blockchain = Blockchain.new

      # process simple chain to give us a some confirmed outputs.
      blockchain.load_from_json("simple_chain_1.json")
      blockchain.chain['main'].each{|height, block|
        processor.process_block(block, raise_errors=true)
      }

      # build spend
      prev_tx = blockchain.chain['main']['7'].tx[1]
      key_A = blockchain.new_key('A')
      parent_tx = build_nonstandard_tx(blockchain, [prev_tx], [0], ver=Toshi::CURRENT_TX_VERSION, lock_time=nil, output_pk_script=nil, key_A)

      # build a spend of a spend
      key_B = blockchain.new_key('B')
      new_tx = build_nonstandard_tx(blockchain, [parent_tx], [0], ver=Toshi::CURRENT_TX_VERSION, lock_time=nil, output_pk_script=nil, key_B, fee=10000)

      # push the tx via the API
      post "/transactions", {:hex => new_tx.payload.unpack("H*").first}.to_json
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json['error']).to eq('AcceptToMemoryPool() : transaction missing inputs')

      # look for it
      get "/transactions/#{new_tx.hash}"
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json['hash']).to eq(new_tx.hash)
      expect(json['version']).to eq(1)
      expect(json['lock_time']).to eq(0)
      expect(json['size']).to eq(new_tx.payload.bytesize)
      expect(json['inputs'][0]).to be_nil # missing inputs
      expect(json['outputs'][0]['amount']).to eq(2500000000-10000)
      expect(json['outputs'][0]['spent']).to eq(false)
      script = Bitcoin::Script.new(new_tx.outputs[0].pk_script)
      expect(json['outputs'][0]['script']).to eq(script.to_string)
      expect(json['outputs'][0]['script_hex']).to eq(new_tx.outputs[0].pk_script.unpack("H*")[0])
      expect(json['outputs'][0]['script_type']).to eq('hash160')
      expect(json['outputs'][0]['addresses'][0]).to eq(blockchain.address_from_label('B'))
      expect(json['amount']).to eq(0) # expect amount to be 0 for now
      expect(json['fees']).to eq(0)
      expect(json['confirmations']).to eq(0)
      expect(json['pool']).to eq('orphan')

      # push the parent tx via the API
      post "/transactions", {:hex => parent_tx.payload.unpack("H*").first}.to_json
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json['error']).to be_nil

      # look for the child again
      get "/transactions/#{new_tx.hash}"
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json['hash']).to eq(new_tx.hash)
      expect(json['version']).to eq(1)
      expect(json['lock_time']).to eq(0)
      expect(json['size']).to eq(new_tx.payload.bytesize)
      expect(json['inputs'][0]['previous_transaction_hash']).to eq(parent_tx.hash)
      expect(json['inputs'][0]['output_index']).to eq(0)
      expect(json['inputs'][0]['amount']).to eq(2500000000)
      expect(json['outputs'][0]['amount']).to eq(2500000000-10000)
      expect(json['outputs'][0]['spent']).to eq(false)
      script = Bitcoin::Script.new(new_tx.outputs[0].pk_script)
      expect(json['outputs'][0]['script']).to eq(script.to_string)
      expect(json['outputs'][0]['script_hex']).to eq(new_tx.outputs[0].pk_script.unpack("H*")[0])
      expect(json['outputs'][0]['script_type']).to eq('hash160')
      expect(json['outputs'][0]['addresses'][0]).to eq(blockchain.address_from_label('B'))
      expect(json['amount']).to eq(2500000000-10000) # expect correct amount now
      expect(json['fees']).to eq(10000) # look for the fee too
      expect(json['confirmations']).to eq(0)
      expect(json['pool']).to eq('memory')
    end
  end

  describe 'verify we properly handle /addresses/:hash/unspent_outputs' do
    it 'make sure we find unspent outputs with proper confirmations' do
      processor = Toshi::Processor.new
      blockchain = Blockchain.new

      blockchain.load_from_json("simple_chain_1.json")
      blockchain.chain['main'].each{|height, block|
        processor.process_block(block, raise_errors=true)
      }

      tx = blockchain.chain['main']['0'].tx[0]
      script = Bitcoin::Script.new(tx.outputs[0].pk_script)
      address = script.get_addresses[0]

      get "/addresses/#{address}/unspent_outputs"
      expect(last_response).to be_ok
      json = JSON.parse(last_response.body)
      expect(json[0]['confirmations']).to eq(Toshi::Models::Block.count)
    end
  end

end
