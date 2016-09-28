require 'spec_helper'
require 'toshi/api/context.rb'

describe Toshi::Web::Api, :type => :request do
  include_context 'shared context'

  it "loads toshi.json" do
    get '/toshi.json'

    expect(last_response).to be_ok
    expect(json['status']).to eq("offline")
  end
end
