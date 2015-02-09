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
end
