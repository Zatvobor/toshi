require 'spec_helper'
require 'toshi/api/context.rb'

describe Toshi::Web::Api, :type => :request do
  include_context 'shared context'
  include_context 'shared hash assertions'

  describe "GET /transactions/<hash>" do
    it "loads transaction" do
      get '/transactions/40d17ca54556e99e1dec77324f99da327c7c6fde243ab069dec1d5b5352fc768'

      expect(last_response).to be_ok
      expect_40d17ca54556e99e1dec77324f99da327c7c6fde243ab069dec1d5b5352fc768_
    end
  end

end
