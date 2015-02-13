require 'spec_helper'

describe Auth::Models::ControlServer do
  describe '#valid?' do
    let(:uuid) { 10.times.map { rand(10) }.join }
    let(:ip) { '64.254.0.1' }
    let(:port) { 87_342 }

    subject { described_class.new(uuid: uuid, ip: ip, port: port) }

    context 'when the uuid is nil' do
      let(:uuid) { nil }

      it { should_not be_valid }
    end

    context 'when the uuid is present' do
      context 'but the port is nil' do
        let(:port) { nil }

        it { should_not be_valid }
      end

      context 'and the port is present' do
        context 'but the ip is nil' do
          let(:ip) { nil }

          it { should_not be_valid }
        end

        context 'and the ip is present' do
          context 'but it is not a valid ip' do
            let(:ips) { %w(999.0.0.0 .0.0.0.0 2.4.5.7. 1000.3.4.2 -1.2.5.5 1.2.3.4.5) }

            it 'should not be valid' do
              expect(ips).to be_none do |ip|
                subject.ip = ip
                subject.valid?
              end
            end
          end

          context 'and it is a valid ip' do
            it { should be_valid }
          end
        end
      end
    end
  end

  describe '#as_json' do
    subject { build(:control_server) }

    it 'returns a Hash representation of the ControlServer' do
      expect(subject.as_json.keys).to eq(%w(id uuid ip port))
    end
  end

  describe '#users' do
    subject { create(:control_server) }
    let(:users) { 3.times.map { build(:user, control_server: subject) } }

    before { users.map(&:save!) }

    it 'returns each user that is associated with the ControlServer' do
      expect(subject.users).to eq(users)
    end
  end
end
