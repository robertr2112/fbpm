FactoryBot.define  do
  factory :user_with_pool, parent: :user do

    transient do
      season   { 1 }
      pool     { nil }
    end

    after(:create) do |user, evaluator|
      if evaluator.pool.nil?
        pool= create(:pool, season: evaluator.season)
        user.admin = true
      else
        pool = evaluator.pool
      end
      user.pools <<  pool
    end
  end

  factory :user_with_pool_and_entry, parent: :user do

    transient do
      season       { 1 }
      num_entries  { 1 }
      pool         { nil }
    end

    after(:create) do |user, evaluator|
      if evaluator.pool.nil?
        user.admin = true
        pool = create(:pool_with_entries, user: user, num_entries: 1, season: evaluator.season)
      else
        pool = evaluator.pool
        pool.entries << create(:entry, user: user, pool: pool)
      end
      user.pools << pool
    end
  end

  factory :pool do
    sequence(:name) { |n| "Pool-#{n}" }
    poolType              { 2 }
    isPublic              { true }
    password              { "foobar" }

    transient do
      week_id      { 1 }
      num_entries  { 1 }
      user         { nil }
    end

    factory :pool_with_entries do
      after (:create) do |pool, evaluator|
        1.upto(evaluator.num_entries) do |n|
          create(:entry, pool: pool, user: evaluator.user)
        end
      end
    end
  end

  # join table factory - :feature
  factory :pool_membership do |membership|
    membership.association :user
    membership.association :pool, :factory => :pool
  end

  factory :game_pick do
    chosenTeamIndex  { 0 }
    pick

  end

  factory :pick do
    week_number { 1 }
    week_id     { nil }
    entry

    transient do
      teamIndex { 0 }
    end

    factory :pick_with_game_pick do
      after (:create) do |pick, evaluator|
        pick.game_picks << create(:game_pick, pick: pick, chosenTeamIndex: evaluator.teamIndex)
      end
    end

  end

  factory :entry do
    sequence(:name)   { |n| "Entry #{n}" }
    survivorStatusIn  { true }
    supTotalPoints    { 0 }
    user
    pool

  end

end
