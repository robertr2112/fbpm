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
      after(:create) do |week, evaluator|
        # All 32 team indices
        teams = (1..32).to_a.shuffle

        # Pair them: [team1, team2], [team3, team4], ...
        pairs = teams.each_slice(2).to_a

        # Anchor dates
        today = Time.zone.today
        sunday = today.beginning_of_week(:sunday) + (week.week_number * 7).days
        monday = sunday + 1.day

        evaluator.num_games.times do |n|
          home_team, away_team = pairs[n]   # ← guaranteed unique pair

          if n == 0
            # Monday game at 18:30
            game_time = monday.to_time.change(hour: 18, min: 30)
          else
            # Sunday games at either 12:00 or 15:00
            kickoff_hour = [ 12, 15 ].sample
            game_time = sunday.to_time.change(hour: kickoff_hour, min: 0)
          end

          create(
            :game,
            week: week,
            homeTeamIndex: home_team,
            awayTeamIndex: away_team,
            game_date: game_time,
            network: [ "CBS", "FOX", "NBC", "ESPN" ].sample
          )
        end
      end
    end
  end
end
