require 'spec_helper'

describe Auth::Models::Session do
  describe '.active' do
    let!(:old_session) { create(:session, expires_on: Time.now - 1.day) }
    let!(:new_session) { create(:session, expires_on: Time.now + 1.day) }

    subject { described_class }

    it 'filters the sessions by those that have not expired' do
      expect(subject.active.to_a).to eq([new_session])
    end
  end

  describe '#valid?' do
    let(:key) { 10.times.map { rand(65) + 25 }.join }
    let(:expires_on) { Time.now + 1.day }
    let(:user) { create(:user) }
    let(:user_id) { user.id }
    let(:attributes) do
      {
        key: key,
        expires_on: expires_on,
        user_id: user_id
      }
    end
    subject { described_class.new(attributes) }

    context 'when the key is nil' do
      let(:key) { nil }

      it 'is not valid' do
        expect(subject).to_not be_valid
      end
    end

    context 'when the key is present' do
      context 'but expires_on is nil' do
        let(:expires_on) { nil }

        it 'is not valid' do
          expect(subject).to_not be_valid
        end
      end

      context 'and expires_on is present' do
        context 'but user_id is nil' do
          let(:user_id) { nil }

          it 'is not valid' do
            expect(subject).to_not be_valid
          end
        end

        context 'and user_id is present' do
          context 'but the user_id does not reference a valid user' do
            let(:user_id) { -1 }

            it 'is not valid' do
              expect(subject).to_not be_valid
            end
          end

          context 'and the user_id references a valid user' do
            it 'is valid' do
              expect(subject).to be_valid
            end
          end
        end
      end
    end
  end

  describe '#expired?' do
    let(:expires_on) { Time.now - 1.day }
    subject { create(:session, expires_on: expires_on) }

    context 'when the session has not expired' do
      it 'returns false' do
        expect(subject).to_not be_expired
      end
    end

    context 'when the session has expired' do
      let(:expires_on) { Time.now + 1.day }

      it 'returns true' do
        expect(subject).to be_expired
      end
    end
  end

  describe '#as_json' do
    subject { create(:session) }

    it 'removes the created_at and updated_at times' do
      expect(subject.as_json.keys).to eq(%w(id key expires_on user_id))
    end
  end

  describe '#user' do
    let(:user) { create(:user) }
    subject { create(:session, user: user) }

    it 'returns that session\'s user' do
      expect(subject.user).to eq(user)
    end
  end
end
