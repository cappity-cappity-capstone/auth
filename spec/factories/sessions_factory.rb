FactoryGirl.define do
  factory :session, class: Auth::Models::Session do
    key { 10.times.map { (65 + rand(25)).chr }.join }
    expires_on { Time.now + 1.day }
    user
  end
end
