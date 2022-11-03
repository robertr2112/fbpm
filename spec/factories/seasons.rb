# == Schema Information
#
# Table name: seasons
#
#  id              :bigint           not null, primary key
#  current_week    :integer
#  nfl_league      :boolean
#  number_of_weeks :integer
#  state           :integer
#  year            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
FactoryBot.define do
  factory :season do
    year             { Time.now.strftime("%Y") }
    state            { 0 }
    nfl_league       { 1 }
    current_week     { 1 }
    number_of_weeks  { 1 }

      transient do
        num_weeks  { 1 }
        num_games  { 1 }
      end

    factory :season_with_weeks do

      after(:create) do |season, evaluator|
       1.upto(evaluator.num_weeks) do |n|
         create(:week, season: season, week_number: n)
       end
       season.number_of_weeks = evaluator.num_weeks
      end
    end

    factory :season_with_weeks_and_games do

      after(:create) do |season, evaluator|
       1.upto(evaluator.num_weeks) do |n|
         create(:week_with_games, season: season, week_number: n, num_games: evaluator.num_games)
       end
       season.number_of_weeks = evaluator.num_weeks
      end
    end
  end
end
