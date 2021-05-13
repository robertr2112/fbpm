
Rails.application.routes.draw do

  root 'seasons#index'

  resources :teams, only: [:edit, :update, :index, :show]
  
  # Seasons and weeks paths
  resources :seasons, shallow: :true do
    resources :weeks
  end

  resources :weeks, only: [:edit, :update, :show, :destroy]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
