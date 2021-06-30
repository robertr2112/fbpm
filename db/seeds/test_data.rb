User.create!(name:  "Example User",
             user_name: "User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar")

99.times do |n|
  name  = Faker::Name.unique.name
  user_name  = Faker::Name.unique.first_name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               user_name: user_name,
               email: email,
               password:              password,
               password_confirmation: password)
end
