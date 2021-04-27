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
require 'rails_helper'

RSpec.describe Season, type: :model do

  let(:season) { FactoryBot.create(:season_with_weeks, num_weeks: 4) }

  subject { season }

  it { should respond_to(:year) }
  it { should respond_to(:state) }
  it { should respond_to(:nfl_league) }
  it { should respond_to(:number_of_weeks) }
  it { should respond_to(:current_week) }
  it { should respond_to(:weeks) }
  it { should respond_to(:setState) }
  it { should respond_to(:isPending?) }
  it { should respond_to(:isOpen?) }
  it { should respond_to(:isClosed?) }
  it { should respond_to(:canBeClosed?) }
  it { should respond_to(:getCurrentWeek) }

  
  describe "Year setting" do
    it "should be set to current year" do
      expect(season.year).to eq Time.now.strftime("%Y")
    end
  end


end

