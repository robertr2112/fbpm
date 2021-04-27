# == Route Map
#
#                    Prefix Verb   URI Pattern                                                                              Controller#Action
#         static_pages_home GET    /static_pages/home(.:format)                                                             static_pages#home
#                      root GET    /                                                                                        static_pages#home
#              season_weeks GET    /seasons/:season_id/weeks(.:format)                                                      weeks#index
#                           POST   /seasons/:season_id/weeks(.:format)                                                      weeks#create
#           new_season_week GET    /seasons/:season_id/weeks/new(.:format)                                                  weeks#new
#                 edit_week GET    /weeks/:id/edit(.:format)                                                                weeks#edit
#                      week GET    /weeks/:id(.:format)                                                                     weeks#show
#                           PATCH  /weeks/:id(.:format)                                                                     weeks#update
#                           PUT    /weeks/:id(.:format)                                                                     weeks#update
#                           DELETE /weeks/:id(.:format)                                                                     weeks#destroy
#                   seasons GET    /seasons(.:format)                                                                       seasons#index
#                           POST   /seasons(.:format)                                                                       seasons#create
#                new_season GET    /seasons/new(.:format)                                                                   seasons#new
#               edit_season GET    /seasons/:id/edit(.:format)                                                              seasons#edit
#                    season GET    /seasons/:id(.:format)                                                                   seasons#show
#                           PATCH  /seasons/:id(.:format)                                                                   seasons#update
#                           PUT    /seasons/:id(.:format)                                                                   seasons#update
#                           DELETE /seasons/:id(.:format)                                                                   seasons#destroy
#                           GET    /weeks/:id/edit(.:format)                                                                weeks#edit
#                           GET    /weeks/:id(.:format)                                                                     weeks#show
#                           PATCH  /weeks/:id(.:format)                                                                     weeks#update
#                           PUT    /weeks/:id(.:format)                                                                     weeks#update
#                           DELETE /weeks/:id(.:format)                                                                     weeks#destroy
#        rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
# rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#        rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
# update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#      rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create

Rails.application.routes.draw do

  root 'seasons#index'

  # Seasons and weeks paths
  resources :seasons, shallow: :true do
    resources :weeks
  end

  resources :weeks, only: [:edit, :update, :show, :destroy]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
