require 'rails_helper'

RSpec.describe SeasonsController, type: :controller do
  let(:season) { create(:season) }

  before do
    allow_any_instance_of(SeasonsController).to receive(:activated_user)
    allow_any_instance_of(SeasonsController).to receive(:admin_user)
    allow_any_instance_of(ApplicationController).to receive(:require_authentication)
    allow(controller).to receive(:render).and_return(nil)
  end

  describe 'GET #season_diagnostics' do
    it 'assigns the season (delegation handled via service in other actions)' do
      begin
        get :season_diagnostics, params: { id: season.id }
      rescue ActionController::MissingExactTemplate, ActionController::UnknownFormat
        # ignore missing template in controller specs — we only assert assignment
      end

      expect(controller.instance_variable_get(:@season)).to eq(season)
    end
  end

  describe 'GET #season_diag_chg' do
    it 'delegates change handling to Diagnostics::SeasonDiagnostics and redirects' do
      service_double = instance_double(Diagnostics::SeasonDiagnostics)
      allow(Diagnostics::SeasonDiagnostics).to receive(:new).and_return(service_double)
      expect(service_double).to receive(:handle_change).with(hash_including('id' => season.id.to_s)).and_return(season)

      get :season_diag_chg, params: { id: season.id }

      expect(response).to redirect_to(season_diagnostics_path(season))
    end

    it 'redirects to seasons index when the service cannot find the season' do
      service_double = instance_double(Diagnostics::SeasonDiagnostics)
      allow(Diagnostics::SeasonDiagnostics).to receive(:new).and_return(service_double)
      expect(service_double).to receive(:handle_change).with(hash_including('id' => season.id.to_s)).and_raise(ActiveRecord::RecordNotFound)

      get :season_diag_chg, params: { id: season.id }

      expect(response).to redirect_to(seasons_path)
      expect(flash[:danger]).to eq('The season you tried to access does not exist')
    end
  end
end
