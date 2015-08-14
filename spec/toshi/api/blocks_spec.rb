require 'spec_helper'
require 'toshi/api/context.rb'

describe Toshi::Web::Api, :type => :request do
  include_context 'shared context'

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

    it 'loads blocks with branch param' do
      get '/blocks', {limit: 1, branch: 'orphan'}

      expect(last_response).to be_ok
      expect(json.count).to eq(0)
    end
  end

  describe "GET /blocks/<block>" do
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

    it "loads latest block" do
      get '/blocks/latest'

      expect(last_response).to be_ok
      expect(json['height']).to eq(7)
      expect(json['branch']).to eq('main')
    end

    it "loads latest block by time" do
      get '/blocks/latest', {time: 2}

      expect(last_response).to be_ok
      expect(json['height']).to eq(2)
      expect(json['branch']).to eq('main')
    end
  end

  describe "GET /blocks/<block>/transactions" do
    it "loads transactions" do
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

    it "loads latest transactions" do
      get '/blocks/latest/transactions'

      expect(last_response).to be_ok
      expect(json['height']).to eq(7)
      expect(json['branch']).to eq('main')
      expect(json['transactions'].count).to eq(2)
    end

    it "loads latest transactions by time" do
      get '/blocks/latest/transactions', {time: 3}

      expect(last_response).to be_ok
      expect(json['height']).to eq(3)
      expect(json['branch']).to eq('main')
      expect(json['transactions'].count).to eq(1)
    end
  end

end
