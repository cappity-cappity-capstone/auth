require 'spec_helper'

describe Auth::Models::User do
  describe '#valid?' do
    let(:name) { 'Joey' }
    let(:email) { 'joey@joemail.joe' }
    let(:password_salt) { 'salty' }
    let(:password_hash) { 'hashy' }
    let(:attributes) do
      {
        name: name,
        email: email,
        password_salt: password_salt,
        password_hash: password_hash
      }
    end

    subject { described_class.new(attributes) }

    context 'when there is no name' do
      let(:name) { nil }

      it 'is not valid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when there is a name' do
      context 'but there is no email' do
        let(:email) { nil }

        it 'is not valid' do
          expect(subject).to_not be_valid
        end
      end

      context 'and there is an email' do
        context 'but there is no password salt' do
          let(:password_salt) { nil }

          it 'is not valid' do
            expect(subject).to_not be_valid
          end
        end

        context 'and there is a password salt' do
          context 'but there is no password hash' do
            let(:password_hash) { nil }

            it 'is not valid' do
              expect(subject).to_not be_valid
            end
          end

          context 'and there is a password hash' do
            context 'but there is a user with the specified email' do
              before { subject.dup.save! }

              it 'is not valid' do
                expect(subject).to_not be_valid
              end
            end

            context 'and there is no user with the specified email' do
              it 'is not valid' do
                expect(subject).to be_valid
              end
            end
          end
        end
      end
    end
  end

  describe '#as_json' do
    subject { build(:user) }

    it 'does not include the password hash' do
      expect(subject.as_json.keys).to eq(%w(id name email control_server))
    end
  end

  describe '#sessions' do
    let!(:session_one) { create(:session, user: subject, expires_on: Time.now - 1.day) }
    let!(:session_two) { create(:session, user: subject, expires_on: Time.now + 1.day) }

    subject { create(:user) }

    it 'returns a list of that user\'s sessions' do
      expect(subject.sessions).to eq([session_one, session_two])
      expect(subject.sessions.active).to eq([session_two])
    end
  end

  describe '#control_server' do
    let(:control_server) { create(:control_server) }
    subject { create(:user, control_server: control_server) }

    context 'when it is not associated with a control_server' do
      let(:control_server) { nil }

      it 'returns nil' do
        expect(subject.control_server).to be_nil
      end
    end

    context 'when it is associated with a control server' do
      it 'returns that control server' do
        expect(subject.control_server).to eq(control_server)
      end
    end
  end
end
