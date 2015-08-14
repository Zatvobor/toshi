require 'spec_helper'
require 'toshi/api/context.rb'

describe Toshi::Web::Api, :type => :request do
  include_context 'shared context'

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

    it "loads address & transactions which is ordered by :confirmations" do
      get '/addresses/moAumqqZYBWDBYMVJAm21ERnnKGTWAaPpj/transactions?order_by=confirmations'

      expect(last_response).to be_ok
      expect(json['no_transactions']).to be(2)

      expect(json['transactions'][0]['confirmations']).to eq(7)
      expect(json['transactions'][1]['confirmations']).to eq(1)
    end

    it "loads address & transactions which is ordered by :block_time" do
      get '/addresses/moAumqqZYBWDBYMVJAm21ERnnKGTWAaPpj/transactions?order_by=block_time'

      expect(last_response).to be_ok
      expect(json['no_transactions']).to be(2)

      expect(json['transactions'][0]['block_time']).to eq("2014-06-07T23:40:13Z")
      expect(json['transactions'][1]['block_time']).to eq("2014-06-07T23:37:25Z")
    end

    it "loads address & transactions which is ordered by :hash" do
      get '/addresses/moAumqqZYBWDBYMVJAm21ERnnKGTWAaPpj/transactions?order_by=hash'

      expect(last_response).to be_ok
      expect(json['no_transactions']).to be(2)

      expect(json['transactions'][0]['hash']).to eq("69fa8e33e585b8b02e69bba854d396030afe6feb75a5686972347d487c481f28")
      expect(json['transactions'][1]['hash']).to eq("3f76051f0cfe131a21efce3271a745f98656c7721987ae2984ae4d20dead957c")
    end


    it "loads address & transactions which is ordered by :amount" do
      get '/addresses/moAumqqZYBWDBYMVJAm21ERnnKGTWAaPpj/transactions?order_by=amount'

      expect(last_response).to be_ok
      expect(json['no_transactions']).to be(2)

      expect(json['transactions'][0]['amount']).to eq(5000000000)
      expect(json['transactions'][1]['amount']).to eq(5000000000)
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

end
