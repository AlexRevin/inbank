FactoryGirl.define do
  factory :prediction do
    source_currency 1
    target_currency 1
    rate ""
    date "2017-10-31"
    algo 1
  end
end
