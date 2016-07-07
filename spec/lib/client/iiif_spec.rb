require 'spec_helper'

describe Geomonitor::Client::Iiif do
  let(:host) { create(:host, url: 'http://www.example.com/iiif') }
  let(:layername) { 'http://libimages.princeton.edu/loris2/pudl0076%2Fmap_pownall%2F00000001.jp2/info.json' }
  let(:layer) { create(
    :layer,
    host_id: host.id,
    name: 'princeton-02870w62c',
    layername: layername,
    access: 'Public',
    bbox: '38.6693 -76.3394 46.5798 -72.1916'
    )
  }
  let(:client) { Geomonitor::Client::Iiif.new(layer) }

  describe 'url' do
    it 'returns iiif layername' do
      expect(client.url).to eq layername
    end
  end

  describe 'create_response' do
    it 'kicks off and ends timers' do
      expect(client.elapsed_time).to be_nil
      client.create_response
      expect(client.elapsed_time).to_not be_nil
    end
    it 'creates a Geomonitor::Response' do
      expect(client.create_response).to be_an Geomonitor::Response
    end
  end
  describe 'grab_iiif_document' do
    let(:response) { double('response') }
    let(:get) { double('get') }
    it 'request iiif doc from server' do
      expect(response).to receive(:get).and_return(get)
      expect(Faraday).to receive(:new).with(url: layername).and_return(response)
      client.grab_iiif_document
    end
    it 'raises a Geomonitor::Exceptions::IiifDocumentGrabFailed when Faraday ConnentionFailed' do
      expect(response).to receive(:url_prefix).and_return layername
      expect(response).to receive(:get).and_raise(Faraday::Error::ConnectionFailed.new('Failed'))
      expect(Faraday).to receive(:new).with(url: layername).and_return(response)
      expect { client.grab_iiif_document }.to raise_error(Geomonitor::Exceptions::IiifDocumentGrabFailed)
    end
    it 'raises a Geomonitor::Exceptions::IiifDocumentGrabFailed when Faraday TimeoutError' do
      expect(response).to receive(:url_prefix).and_return layername
      expect(response).to receive(:get).and_raise(Faraday::Error::TimeoutError.new('Failed'))
      expect(Faraday).to receive(:new).with(url: layername).and_return(response)
      expect { client.grab_iiif_document }.to raise_error(Geomonitor::Exceptions::IiifDocumentGrabFailed)
    end
  end
end
