FactoryBot.define do
  factory :user do
    trait :valid do
      email    { 'someuser@gmail.com' }
      password { 'strong_password' }
    end

    trait :invalid do
      email    { 'someemail' }
      password { '1234' }
    end
  end
end
