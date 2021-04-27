# == Schema Information
#
# Table name: games
#
#  id            :bigint           not null, primary key
#  awayTeamIndex :integer
#  awayTeamScore :integer
#  game_date     :datetime
#  homeTeamIndex :integer
#  homeTeamScore :integer
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
require 'rails_helper'

RSpec.describe Game, type: :model do

  let(:season) { FactoryBot.create(:season) }
  let(:week)   { FactoryBot.create(:week) }

  before(:each) do
    @game= week.games.create(homeTeamIndex: 0, awayTeamIndex: 1,
                              spread: 3.5)
  end

  subject {@game}

  it { should respond_to(:week_id) }
  it { should respond_to(:homeTeamIndex) }
  it { should respond_to(:awayTeamIndex) }
  it { should respond_to(:spread) }
  it { should respond_to(:homeTeamScore) }
  it { should respond_to(:awayTeamScore) }

  it { should be_valid }

end
