require 'spec_helper'

describe Auth::Controllers::Users do
  include Rack::Test::Methods

  let(:app) { described_class.new }

  describe 'POST /users/' do
    context 'when invalid options are passed' do
      let(:options) { { invalid_option: 400 } }

      it 'returns a 400' do
        post '/users/', options.to_json
        expect(last_response.status).to eq(400)
      end
    end

    context 'when valid options are passed' do
      let(:name) { 'Sean Carter' }
      let(:email) { 'seancarter@gmail.com' }
      let(:password) { 'i<3yonce' }
      let(:options) do
        {
          'name' => name,
          'email' => email,
          'password' => password
        }
      end

      context 'but the email is already registered' do
        before { Auth::Services::Users.create(options) }

        it 'returns a 409' do
          post '/users/', options.to_json
          expect(last_response.status).to eq(409)
        end
      end

      context 'and the email is not already registered' do
        let(:body) { JSON.parse(last_response.body) }

        it 'creates a new user' do
          post '/users/', options.to_json

          expect(last_response.status).to eq(201)

          expect(body['name']).to eq(name)
          expect(body['email']).to eq(email)

          expect(body['id']).to be_present

          expect(body['password_salt']).to be_blank
          expect(body['password_hash']).to be_blank
          expect(body['password']).to be_blank
        end
      end
    end
  end

  describe 'PUT /users/:id/' do
    context 'when no such id is exists' do
      it 'returns a 404' do
        put '/users/0', {}.to_json

        expect(last_response.status).to eq(404)
      end
    end

    context 'when the given id exists' do
      let(:user) { create(:user) }

      context 'but the user options are invalid' do
        let(:options) { { EMAIL: 'jimmy@jimmy.jimmy' } }

        it 'returns a 400' do
          put "/users/#{user.id}", options.to_json

          expect(last_response.status).to eq(400)
        end
      end

      context 'and the user options are valid' do
        context 'but the email is updated to an existing email' do
          let(:user_two) { create(:user) }
          let(:options) { { email: user_two.email } }

          it 'returns a 409' do
            put "/users/#{user.id}", options.to_json

            expect(last_response.status).to eq(409)
          end
        end

        context 'and the email is not updated to an existing email' do
          let(:name) { 'Fat Tony' }
          let(:email) { 'some@email.com' }
          let(:options) { { name: name, email: email } }

          it 'returns a 200' do
            put "/users/#{user.id}", options.to_json

            expect(last_response.status).to eq(200)
            user.reload
            expect(user.name).to eq(name)
            expect(user.email).to eq(email)
          end

          context 'when a password_salt or hash is updated' do
            let(:password_salt) { 'salt' }
            let(:password_hash) { 'hash' }
            let(:options) do
              {
                password_salt: password_salt,
                password_hash: password_hash
              }
            end

            it 'does not allow them to be updated' do
              original_password_salt = user.password_salt
              original_password_hash = user.password_hash
              put "/users/#{user.id}", options.to_json

              expect(last_response.status).to eq(200)
              user.reload
              expect(user.password_salt).to eq(original_password_salt)
              expect(user.password_hash).to eq(original_password_hash)
            end
          end
        end
      end
    end
  end

  describe 'DELETE /users/:id/' do
    context 'when the user does not exist' do
      it 'returns a 404' do
        delete '/users/0'

        expect(last_response.status).to eq(404)
      end
    end

    context 'when the users exists' do
      let(:user) { create(:user) }

      it 'deletes the user and returns a 204' do
        delete "/users/#{user.id}"

        expect(last_response.status).to eq(204)
        expect(Auth::Models::User.exists?(email: user.email)).to be_falsey
      end
    end
  end
end
