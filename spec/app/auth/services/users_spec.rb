require 'spec_helper'

describe Auth::Services::Users do
  describe '#create' do
    let(:name) { 'joey' }
    let(:email) { 'joey@joemail.net' }
    let(:password) { 'trustno1' }
    let(:attributes) do
      {
        'name' => name,
        'email' => email,
        'password' => password
      }
    end

    context 'when a required attribute is blank' do
      let(:bad_options) do
        %w(name email password).flat_map do |attr|
          [
            { attr => nil },
            { attr => '' }
          ]
        end
      end

      it 'raises a BadModelOptions error' do
        bad_options.each do |options|
          expect { subject.create(attributes.merge(options)) }
            .to raise_error(Auth::Errors::BadModelOptions)
        end
      end
    end

    describe 'when all required attributes are given' do
      context 'but a user with the given email already exists' do
        before { subject.create(attributes) }

        it 'raises a ConflictingModelOptions error' do
          expect { subject.create(attributes) }
            .to raise_error(Auth::Errors::ConflictingModelOptions)
        end
      end

      context 'and no user with the given email exists' do
        it 'creates a new user' do
          expect { subject.create(attributes) }
            .to change { Auth::Models::User.find_by(email: attributes['email']).nil? }
            .from(true)
            .to(false)
        end
      end
    end
  end

  describe '#read' do
    context 'when the email does not exist' do
      it 'raises a NoSuchModel error' do
        expect { subject.read(0) }
          .to raise_error(Auth::Errors::NoSuchModel)
      end
    end

    context 'when the email exists' do
      let(:name) { 'Dan Osbourne' }
      let(:email) { 'djosborne10@gmail.com' }
      let(:password) { 'Juggernaut4' }
      let(:attributes) do
        {
          'name' => name,
          'email' => email,
          'password' => password
        }
      end
      let(:user) { subject.create(attributes) }

      it 'returns a Hash representing that user' do
        expect(subject.read(user['id']).values_at('name', 'email')).to eq([name, email])
      end
    end
  end

  describe '#update' do
    context 'when the email does not exist' do
      it 'raises a NoSuchModel error' do
        expect { subject.update(0, 'name' => 'A$AP Rocky') }
          .to raise_error(Auth::Errors::NoSuchModel)
      end
    end

    context 'when the email exists' do
      let(:name) { 'Slim Jim' }
      let(:email) { 'thinjames@gmail.com' }
      let(:password) { 'krisykreme' }
      let(:attributes) do
        {
          'name' => name,
          'email' => email,
          'password' => password
        }
      end
      let(:user) { subject.create(attributes) }

      context 'but invalid options are passed' do
        it 'raises a BadModelOptions error' do
          expect { subject.update(user['id'], 'NAME' => 'Thin James') }
            .to raise_error(Auth::Errors::BadModelOptions)
        end
      end

      context 'and valid options are passed' do
        it 'updates the user' do
          expect { subject.update(user['id'], 'name' => 'Thin James') }
            .to change { subject.read(user['id'])['name'] }
            .from('Slim Jim')
            .to('Thin James')
        end

        context 'and a password is being updated' do
          it 'updates the password hash' do
            expect { subject.update(user['id'], 'password' => 'trustno1') }
              .to change { Auth::Models::User.find(user['id']).password_hash }
          end
        end
      end
    end
  end

  describe '#destroy' do
    context 'when the email does not exist' do
      it 'raises a NoSuchModel error' do
        expect { subject.destroy(0) }
          .to raise_error(Auth::Errors::NoSuchModel)
      end
    end

    context 'when the email exists' do
      let(:name) { 'Ronald McDonald' }
      let(:email) { 'ronmcdon@mcdonalds.com' }
      let(:password) { '<3bigburd' }
      let(:attributes) do
        {
          'name' => name,
          'email' => email,
          'password' => password
        }
      end
      let!(:user) { subject.create(attributes) }

      it 'destroys that user' do
        expect { subject.destroy(user['id']) }
          .to change { Auth::Models::User.find_by(email: email).nil? }
          .from(false)
          .to(true)
      end
    end
  end

  describe '#authenticate' do
    let(:name) { 'Lol Aol' }
    let(:email) { 'lol@aol.email' }
    let(:given_password) { '' }
    let(:saved_password) { 'yahooligans' }
    let(:attributes) { { 'name' => name, 'email' => email, 'password' => saved_password } }

    context 'when the user does not exist' do
      it 'returns false' do
        expect(subject.authenticate(email, given_password)).to be_falsey
      end
    end

    context 'when the user exists' do
      let!(:user) { subject.create(attributes) }

      context 'but the password is not the user\'s password' do
        let(:given_password) { "~#{saved_password}~" }

        it 'returns false' do
          expect(subject.authenticate(email, given_password)).to be_falsey
        end
      end

      context 'and the password is the user\'s password' do
        let(:given_password) { saved_password }

        it 'returns true' do
          expect(subject.authenticate(email, given_password)).to be_truthy
        end
      end
    end
  end

  describe '#for_session' do
    context 'when the given session has no associated user' do
      it 'returns nil' do
        expect(subject.for_session('some key')).to be_nil
      end
    end

    context 'when the given session has an associated user' do
      context 'but it is expired' do
        let(:session) { create(:session, expires_on: 1.day.ago) }

        it 'returns nil' do
          expect(subject.for_session(session.key)).to be_nil
        end
      end

      context 'and it is not expired' do
        let(:session) { create(:session) }

        it 'returns that user' do
          expect(subject.for_session(session.key)).to eq(session.user)
        end
      end
    end
  end
end
