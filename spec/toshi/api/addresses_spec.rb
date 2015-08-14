require 'spec_helper'
require 'toshi/api/context.rb'

describe Toshi::Web::Api, :type => :request do
  include_context 'shared context'
  include_context 'shared hash assertions'

  describe "GET /addresses/<hash>" do
    it "loads address" do
      get '/addresses/mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz'

      expect(last_response).to be_ok
      expect_mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz_
    end
  end

  describe "GET /addresses/<hash>/transactions" do
    it "loads address & transactions" do
      get '/addresses/mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz/transactions'

      expect(last_response).to be_ok
      expect_mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz_
      expect_40d17ca54556e99e1dec77324f99da327c7c6fde243ab069dec1d5b5352fc768_(json['transactions'][0])
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

  describe "GET /addresses/<hash>/balance_at.json" do
    it "returns balance, target address and block info" do
      get '/addresses/mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz/balance_at'

      expect(json['balance']).to eq(5_000_000_000)
      expect(json['address']).to eq("mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz")
      expect(json['block_height']).to eq(7)
      expect(json['block_time']).to eq(1402184413)
    end

    it "will return a balance of 0 if there are no transactions found" do
      get '/addresses/mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz/balance_at?time=5'

      expect(json['balance']).to eq(0)
      expect(json['address']).to eq("mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz")
      expect(json['block_height']).to eq(5)
      expect(json['block_time']).to eq(1402184357)
    end

    it "uses block height if time is below five hundred thousand" do
      get '/addresses/mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz/balance_at?time=6'

      expect(json['balance']).to eq(5_000_000_000)
      expect(json['address']).to eq("mw851HctCPZUuRCC4KktwKCJQqBz9Xwohz")
      expect(json['block_height']).to eq(6)
      expect(json['block_time']).to eq(1402184385)
    end
  end

end
