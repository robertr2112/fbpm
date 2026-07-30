require 'rails_helper'

RSpec.describe PoolsController, type: :controller do
  let(:season) { create(:season) }
  let(:pool)   { create(:pool, season: season) }

  before do
    # Bypass authentication/authorization filters for controller tests
    allow_any_instance_of(PoolsController).to receive(:activated_user)
    allow_any_instance_of(PoolsController).to receive(:admin_user)
    # Bypass global authentication (require_authentication) defined in Authentication concern
    allow_any_instance_of(ApplicationController).to receive(:require_authentication)
    # Avoid template rendering during controller unit tests
    allow(controller).to receive(:render).and_return(nil)
  end

  describe 'GET #pool_diagnostics' do
    it 'delegates to Diagnostics::PoolDiagnostics and assigns season' do
      service_double = instance_double(Diagnostics::PoolDiagnostics)
      allow(Diagnostics::PoolDiagnostics).to receive(:new).and_return(service_double)
      expect(service_double).to receive(:show).with(pool).and_return({ pool: pool, season: season })

      begin
        get :pool_diagnostics, params: { id: pool.id }
      rescue ActionController::MissingExactTemplate, ActionController::UnknownFormat
        # ignore missing template in controller specs — we only assert delegation
      end

      expect(controller.instance_variable_get(:@pool)).to eq(pool)
      expect(controller.instance_variable_get(:@season)).to eq(season)
    end
  end

  describe 'GET #pool_diag_chg' do
    it 'delegates change handling to Diagnostics::PoolDiagnostics and redirects' do
      stub_pool = pool
      service_double = instance_double(Diagnostics::PoolDiagnostics)
      allow(Diagnostics::PoolDiagnostics).to receive(:new).and_return(service_double)
      expect(service_double).to receive(:handle_change).with(hash_including('id' => pool.id.to_s)).and_return(stub_pool)

      get :pool_diag_chg, params: { id: pool.id }

      expect(response).to redirect_to(pool_diagnostics_path(stub_pool))
    end
  end
end
