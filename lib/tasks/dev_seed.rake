# lib/tasks/dev_seed.rake
namespace :dev do
  desc "Seed development DB using FactoryBot"
  task seed: :environment do
    require "factory_bot_rails"
    include FactoryBot::Syntax::Methods

    puts "Seeding users..."

    # Regular users
    users = create_list(:user, 25)
    puts "Created #{users.count} regular users"

    puts "Create season with 5 weeks and 5 games per week..."
      season = FactoryBot.create(:season_with_weeks_and_games, num_weeks: 5, num_games: 5)

    puts "Seeding pool..."

    # Create pool
    # FactoryBot.create(:user_with_pool_and_entry, season: season, user: users[0])
    # pool = users[0].pools.first
    # 1.upto(4) do |n|
    #  FactoryBot.create(:user_with_pool_and_entry, season: season, pool: pool, user: users[n])
    # end
    # Create a pool owned by the first user
    pool = create(:pool, season: season)

    # Owner membership
    create(:pool_membership, pool: pool, user: users[0], owner: true)
    create(:entry, pool: pool, user: users[0])

    puts "Adding 4 more users to the pool..."

    1.upto(4) do |n|
      create(:pool_membership, pool: pool, user: users[n])
      create(:entry, pool: pool, user: users[n])
    end

    puts "Development DB seeded successfully!"
  end
end
