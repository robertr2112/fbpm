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
# Foreign Keys
#
#  fk_rails_...  (season_id => seasons.id)
#
require 'rails_helper'

RSpec.describe Week, type: :model do

  let(:season) { FactoryBot.create(:season_with_weeks, num_weeks: 1) }

  before(:each) do
    @week = season.weeks.first
  end

  subject {@week}

  it { should respond_to(:state) }
  it { should respond_to(:season_id) }
  it { should respond_to(:week_number) }
  it { should respond_to(:games) }

  it { should be_valid }

  it "should have the right associated season_id" do
    season_id = @week.season_id
    expect(season_id).to eq season.id
  end

end
