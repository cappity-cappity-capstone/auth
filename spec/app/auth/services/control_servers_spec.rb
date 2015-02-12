require 'spec_helper'

describe Auth::Services::ControlServers do
  describe '.create' do
    let(:uuid) { 10.times.map { rand(10) }.join }
    let(:ip) { '52.12.9.2' }
    let(:port) { 29_221 }

    context 'when the UUID already exists in the database' do
      before { subject.create(uuid, ip, port) }

      it 'raises a ConflictingModelOptions error' do
        expect { subject.create(uuid, ip, port) }
          .to raise_error(Auth::Errors::ConflictingModelOptions)
      end
    end

    context 'when the UUID is new' do
      context 'but the data is invalid' do
        let(:ip) { 'lol not ip' }

        it 'raises a BadModelOptions error' do
          expect { subject.create(uuid, ip, port) }
            .to raise_error(Auth::Errors::BadModelOptions)
        end
      end

      context 'and the data is valid' do
        it 'creates a new ControlServer' do
          expect { subject.create(uuid, ip, port) }
            .to change { Auth::Models::ControlServer.exists?(uuid: uuid, ip: ip, port: port) }
            .from(false)
            .to(true)
        end
      end
    end
  end

  describe '.update' do
    let(:control_server) { build(:control_server, ip: '123.45.67.80') }
    let(:ip) { '123.45.67.89' }
    let(:attrs) { { ip: ip } }

    context 'when the uuid cannot be found' do
      it 'raises a NoSuchModel error' do
        expect { subject.update(control_server.uuid, attrs) }
          .to raise_error(Auth::Errors::NoSuchModel)
      end
    end

    context 'when the uuid can be found' do
      before { control_server.save! }

      context 'but the data is invalid' do
        let(:ip) { 'eye pee' }

        it 'raises a BadModelOptions error' do
          expect { subject.update(control_server.uuid, attrs) }
            .to raise_error(Auth::Errors::BadModelOptions)
        end
      end

      context 'and the data is valid' do
        it 'updates the attributes' do
          expect { subject.update(control_server.uuid, attrs) }
            .to change { Auth::Models::ControlServer.exists?(ip: ip) }
            .from(false)
            .to(true)
        end
      end
    end
  end

  describe '.for_ip' do
    let(:control_server) { build(:control_server) }

    context 'when the given ip is in the database' do
      it 'raises a NoSuchModel error' do
        expect { subject.for_ip(control_server.ip) }
          .to raise_error(Auth::Errors::NoSuchModel)
      end
    end

    context 'when the given ip is in the database' do
      before { control_server.save! }

      it 'returns that control_server' do
        expect(subject.for_ip(control_server.ip)).to eq(control_server.as_json)
      end
    end
  end
end
