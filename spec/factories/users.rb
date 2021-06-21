
FactoryBot.define  do
  factory :user do
    sequence(:name)       { |n| "Person #{n}" }
    sequence(:user_name)  { |n| "Nickname #{n}" }
    sequence(:email)      { |n| "person-#{n}@example.com" }
    password              { "foobar" }
    password_confirmation { "foobar" }
    confirmed             { true }

    factory :supervisor do
      supervisor { true }
      admin      { true }
    end

    factory :admin do
      admin { true }
    end

    factory :unconfirmed_user do
      confirmed { false }
    end
  end
end
