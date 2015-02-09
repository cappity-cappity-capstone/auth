FactoryGirl.define do
  factory :user, class: Auth::Models::User do
    name 'Joey'
    sequence(:email) { |n| "liljoey#{n}@joemail.com" }
    password_salt { 10.times.map { (65 + rand(25)).chr }.join }
    password_hash { 15.times.map { (65 + rand(25)).chr }.join }
  end
end
