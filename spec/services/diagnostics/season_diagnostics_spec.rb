require 'rails_helper'

RSpec.describe Diagnostics::SeasonDiagnostics, type: :service do
  describe '#handle_change' do
    context 'when cur_week param is provided' do
      it 'updates the season current_week' do
        season = FactoryBot.create(:season, current_week: 1)
        service = described_class.new

        service.handle_change({ id: season.id, cur_week: true, number: 3 })
        expect(season.reload.current_week).to eq(3)
      end
    end

    context 'when chg_week_state param is provided' do
      it 'updates the specified week state' do
        week = FactoryBot.create(:week, state: 0)
        service = described_class.new

        service.handle_change({ id: week.season.id, chg_week_state: true, week: week.id, state: 2 })
        expect(week.reload.state).to eq(2)
      end
    end

    context 'when update_nfl_team_info param is provided' do
      it 'fixes common team name typos' do
        Team.create!(name: 'Cinncinatti Bengals', nfl: true)
        Team.create!(name: 'St Louis Rams', nfl: true)

        service = described_class.new
        season = FactoryBot.create(:season)

        service.handle_change({ id: season.id, update_nfl_team_info: true })

        expect(Team.find_by(name: 'Cincinnati Bengals')).to be_present
        expect(Team.find_by(name: 'Los Angeles Rams')).to be_present
      end
    end
  end
end
