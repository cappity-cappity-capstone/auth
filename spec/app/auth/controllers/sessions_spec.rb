require 'spec_helper'

describe Auth::Controllers::Sessions do
  include Rack::Test::Methods

  let(:app) { described_class.new }

  describe 'POST /sessions/' do
    let(:name) { 'Cappy' }
    let(:email) { 'cappy@capstone.net' }
    let(:password) { 'ayy lmao' }
    let(:attributes) { { email: email, password: password } }

    context 'when an invalid email is given' do
      it 'returns a 404' do
        post '/sessions/', attributes.to_json

        expect(last_response.status).to eq(404)
      end
    end

    context 'when a valid email is given' do
      let!(:user) do
        Auth::Services::Users.create(
          'name' => name,
          'email' => email,
          'password' => password
        )
      end

      context 'but the password does not match' do
        before { attributes['password'] = password.reverse }

        it 'returns a 401' do
          post '/sessions/', attributes.to_json

          expect(last_response.status).to eq(401)
        end
      end

      context 'and the password matches' do
        let(:resp) { JSON.parse(last_response.body) }

        it 'sets the session_key cookie and returns the session as json' do
          post '/sessions', attributes.to_json

          expect(last_response.status).to eq(201)
          expect(last_response.header['Set-Cookie']).to match(/session_key=[^;]+; expires=/)
          expect(resp['id']).to be_present
          expect(resp['key']).to be_present
          expect(resp['expires_on']).to be_present
        end
      end
    end
  end

  describe 'DELETE /sessions/' do
    let(:session) { build(:session) }

    before { set_cookie "session_key=#{session.key}" }

    context 'but the session cookie cannot be found in the database' do
      it 'returns a 404' do
        delete '/sessions/'

        expect(last_response.status).to eq(404)
      end
    end

    context 'and the session cookie can be found in the database' do
      before { session.save! }

      it 'returns a 204' do
        delete '/sessions/'

        expect(last_response.status).to eq(204)
        expect(last_response.header['Set-Cookie']).to match(/session_key=;/)
      end
    end
  end
end
