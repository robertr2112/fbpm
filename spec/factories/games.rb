# == Schema Information
#
# Table name: games
#
#  id            :bigint           not null, primary key
#  awayTeamIndex :integer
#  awayTeamScore :integer          default(0)
#  game_date     :datetime
#  homeTeamIndex :integer
#  homeTeamScore :integer          default(0)
#  spread        :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  week_id       :bigint
#
# Indexes
#
#  index_games_on_week_id  (week_id)
#
# Foreign Keys
#
#  fk_rails_...  (week_id => weeks.id)
#
FactoryBot.define do

  factory :game do
    sequence(:homeTeamIndex, (1..16).cycle) { |n| n }
    sequence(:awayTeamIndex, (17..32).cycle) { |n| n }
    game_date { Time.zone.now + 10.minutes }
    week
  end

end
