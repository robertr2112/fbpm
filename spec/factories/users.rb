# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  activated              :boolean          default(FALSE)
#  activated_at           :datetime
#  activation_digest      :string
#  admin                  :boolean          default(FALSE)
#  contact                :integer          default(1)
#  email                  :string
#  name                   :string
#  password_digest        :string
#  password_reset_sent_at :datetime
#  password_reset_token   :string
#  phone                  :string
#  remember_digest        :string
#  supervisor             :boolean          default(FALSE)
#  user_name              :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email            (email) UNIQUE
#  index_users_on_remember_digest  (remember_digest)
#
FactoryBot.define  do
  factory :user do
    sequence(:name)       { |n| "Person #{n}" }
    sequence(:user_name)  { |n| "Nickname #{n}" }
    sequence(:email)      { |n| "person-#{n}@example.com" }
    contact               { 2 }
    phone                 { "555-123-4567" }
    password              { "foobar" }
    password_confirmation { "foobar" }
    activated             { true }
    activated_at          { Time.zone.now }

    factory :supervisor do
      supervisor { true }
      admin      { true }
    end

    factory :admin do
      admin { true }
    end

    factory :unactivated_user do
      activated { false }
    end
  end
end
