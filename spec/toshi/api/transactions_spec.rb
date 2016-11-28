require 'spec_helper'
require 'toshi/api/context.rb'

describe Toshi::Web::Api, :type => :request do
  include_context 'shared context'
  include_context 'shared hash assertions'

  describe "GET /transactions/confirmed" do
    it "loads transactions" do
      get '/transactions/confirmed'

      expect(last_response).to be_ok
      expect(json.count).to eq(9)
    end

    it "loads limited amount of transactions" do
      get '/transactions/confirmed?limit=1'

      expect(last_response).to be_ok
      expect(json.count).to eq(1)
    end
  end

  describe "GET /transactions/<hash>" do
    it "loads transaction" do
      get '/transactions/40d17ca54556e99e1dec77324f99da327c7c6fde243ab069dec1d5b5352fc768'

      expect(last_response).to be_ok
      expect_40d17ca54556e99e1dec77324f99da327c7c6fde243ab069dec1d5b5352fc768_
    end

    it "loads transactions by ids" do
      get '/transactions', ids: ["40d17ca54556e99e1dec77324f99da327c7c6fde243ab069dec1d5b5352fc768", "unknown"]
      expect(last_response).to be_ok
      expect(json.length).to eq(1)
      expect_40d17ca54556e99e1dec77324f99da327c7c6fde243ab069dec1d5b5352fc768_(json.first)
    end
  end

end
