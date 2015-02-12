require 'spec_helper'

describe Auth::Controllers::ControlServers do
  include Rack::Test::Methods

  let(:app) { described_class.new }

  describe 'POST /control_servers/' do
    let(:uuid) { 10.times.map { rand(10) }.join }
    let(:ip) { '88.223.72.65' }
    let(:port) { 1234 }
    let(:attributes) { { uuid: uuid, port: port } }

    before { env 'REMOTE_ADDR', ip }

    context 'when the data is invalid' do
      let(:port) { nil }

      it 'returns a 400' do
        post '/control_servers', attributes.to_json

        expect(last_response.status).to eq(400)
      end
    end

    context 'when the data is valid' do
      context 'but the uuid has already been associated' do
        before { Auth::Services::ControlServers.create(uuid, ip, port) }

        it 'returns a 409' do
          post '/control_servers', attributes.to_json

          expect(last_response.status).to eq(409)
        end
      end

      context 'and the uuid is new' do
        let(:body) { JSON.parse(last_response.body) }

        it 'creates a new control_server' do
          expect { post '/control_servers', attributes.to_json }
            .to change { Auth::Models::ControlServer.exists?(attributes) }
            .from(false)
            .to(true)

          expect(last_response.status).to eq(201)
          expect(body['uuid']).to eq(uuid)
          expect(body['ip']).to eq(ip)
          expect(body['port']).to eq(port)
        end
      end
    end
  end

  describe 'PUT /control_servers/:uuid/' do
    let(:control_server) { build(:control_server, port: 1234) }
    let(:port) { 4567 }
    let(:attributes) { { port: port } }

    context 'when the uuid is not in the database' do
      it 'returns a 404' do
        put "/control_servers/#{control_server.uuid}", attributes.to_json

        expect(last_response.status).to eq(404)
      end
    end

    context 'when the uuid is in the database' do
      before { control_server.save! }

      context 'but the data is invalid' do
        let(:port) { nil }

        it 'returns a 400' do
          put "/control_servers/#{control_server.uuid}", attributes.to_json

          expect(last_response.status).to eq(400)
        end
      end

      context 'and the data is valid' do
        it 'updates the model' do
          expect { put "/control_servers/#{control_server.uuid}", attributes.to_json }
            .to change { control_server.tap(&:reload).port }
            .from(control_server.port)
            .to(port)

          expect(last_response.status).to eq(200)
        end
      end
    end
  end
end
