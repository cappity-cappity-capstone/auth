require 'spec_helper'

describe Auth::Services::Sessions do
  describe '.create' do
    let(:name) { 'Email' }
    let(:email) { 'e@mail.com' }
    let(:password) { 'telephone' }
    let(:expires_on) { Time.now + 1.day }

    context 'when the there is no user associated with the given email' do
      it 'raises a NoSuchModel error' do
        expect { subject.create(email, password, expires_on) }
          .to raise_error(Auth::Errors::NoSuchModel)
      end
    end

    context 'when the there is a user associated with the given email' do
      let!(:user) do
        Auth::Services::Users.create(
          'name' => name,
          'email' => email,
          'password' => password
        )
      end

      context 'but the given password does not match the user\'s\ password' do
        it 'raises a BadPassword error' do
          expect { subject.create(email, "~#{password}~", expires_on) }
            .to raise_error(Auth::Errors::BadPassword)
        end
      end

      context 'and the given password matches the user\'s password' do
        it 'creates a new session for that user' do
          expect { subject.create(email, password, expires_on) }
            .to change { Auth::Models::User.find(user['id']).sessions.count }
            .by(1)
        end
      end
    end
  end

  describe '.expire' do
    let(:expires_on) { Time.now - 1.day }
    let(:session) { build(:session, expires_on: expires_on) }

    context 'when the session key cannot be found' do
      it 'raises a NoSuchModel error' do
        expect { subject.expire(session.key) }
          .to raise_error(Auth::Errors::NoSuchModel)
      end
    end

    context 'when the session key can be found' do
      before { session.save! }

      it 'expires the key' do
        expect { subject.expire(session.key) }
          .to change { session.tap(&:reload).expires_on.to_i }
          .from(expires_on.to_i)
      end
    end
  end
end
