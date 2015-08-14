require 'spec_helper'
require 'toshi/api/context.rb'

describe Toshi::Web::Api, :type => :request do
  include_context 'shared context'

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

end
