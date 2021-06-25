# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean          default(FALSE)
#  confirmation_token     :string
#  confirmed              :boolean          default(FALSE)
#  email                  :string
#  name                   :string
#  password_digest        :string
#  password_reset_sent_at :datetime
#  password_reset_token   :string
#  remember_digest        :string
#  supervisor             :boolean          default(FALSE)
#  user_name              :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
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
