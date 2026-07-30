require 'rails_helper'

RSpec.describe Diagnostics::PoolDiagnostics, type: :service do
  describe '#show' do
    it 'returns pool and season in a hash' do
      season = FactoryBot.create(:season)
      pool = FactoryBot.create(:pool, season: season)

      result = described_class.new.show(pool)
      expect(result[:pool]).to eq(pool)
      expect(result[:season]).to eq(season)
    end
  end

  describe '#handle_change' do
    context 'when surv param is provided' do
      it 'toggles the entry survivorStatusIn flag' do
        season = FactoryBot.create(:season)
        pool = FactoryBot.create(:pool, season: season)
        entry = FactoryBot.create(:entry, pool: pool, survivorStatusIn: true)
        service = described_class.new

        service.handle_change({ entry_id: entry.id, surv: true })
        expect(entry.reload.survivorStatusIn).to be_falsey

        service.handle_change({ entry_id: entry.id, surv: true })
        expect(entry.reload.survivorStatusIn).to be_truthy
      end
    end

    context 'when pool_status param is provided' do
      it 'toggles the pool.pool_done flag' do
        season = FactoryBot.create(:season)
        pool = FactoryBot.create(:pool, season: season, pool_done: false)
        service = described_class.new

        service.handle_change({ pool_id: pool.id, pool_status: true })
        expect(pool.reload.pool_done).to be_truthy

        service.handle_change({ pool_id: pool.id, pool_status: true })
        expect(pool.reload.pool_done).to be_falsey
      end
    end

    context 'when neither param provided' do
      it 'returns the pool by id' do
        season = FactoryBot.create(:season)
        pool = FactoryBot.create(:pool, season: season)
        service = described_class.new
        result = service.handle_change({ id: pool.id })
        expect(result).to eq(pool)
      end
    end
  end
end
