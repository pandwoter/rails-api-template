require 'rails_helper'

RSpec.describe User, type: :model do
  context 'User attributes are valid' do
    let (:user) { build_stubbed :user, :valid }

    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'has a unique email' do
      user2 = build(:user, email: 'someuser@gmail.com')
      expect(user2).to_not be_valid
    end
  end

  context 'User attributes are invalid' do
    let (:invalid_user) { build_stubbed :user, :invalid }

    it 'is not valid without a password' do
      user2 = build(:user, password: nil)
      expect(user2).to_not be_valid
    end

    it 'is not valid without an email' do
      user2 = build(:user, email: nil)
      expect(user2).to_not be_valid
    end

    it 'is not valid with password below 6 characters' do
      expect(invalid_user).to_not be_valid
    end
  end
end
