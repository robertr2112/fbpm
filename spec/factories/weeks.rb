# == Schema Information
#
# Table name: weeks
#
#  id          :bigint           not null, primary key
#  state       :integer
#  week_number :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  season_id   :bigint
#
# Indexes
#
#  index_weeks_on_season_id  (season_id)
#
FactoryBot.define do
  factory :week do
    state        { 0 }
    week_number  { 1 }
    season

    transient do
      num_games  { 5 }
    end

    factory :week_with_games do

      after (:create) do |week, evaluator|
        home_games = (1..16).sort_by{rand}
        away_games = (17..32).sort_by{rand}
        1.upto(evaluator.num_games) do |n|
          create(:game, week: week)
#         create(:game, week: week, homeTeamIndex: home_games[n-1],
#                                   awayTeamIndex: away_games[n-1])
        end
      end
    end
  end

end
