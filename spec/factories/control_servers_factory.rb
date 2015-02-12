FactoryGirl.define do
  factory :control_server, class: Auth::Models::ControlServer do
    uuid { 10.times.map { (65 + rand(25)).chr }.join }
    ip '154.24.0.1'
    port { rand(5000) + 4000 }
  end
end
