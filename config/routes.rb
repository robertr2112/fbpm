
Rails.application.routes.draw do

  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :teams, only: [:edit, :update, :index, :show]
  
  # Static routes
  root 'seasons#index' # Temporary root page
  #root  'static_pages#home'
  match '/signup',            to: 'users#new',                    via: 'get'
  match '/signin',            to: 'sessions#new',                 via: 'get'
  match '/signout',           to: 'sessions#destroy',             via: 'delete'

  # Seasons and weeks paths
  match 'weeks/open/:id',       to: 'weeks#open',        as: :open,          via: 'get'
  match 'weeks/closed/:id',     to: 'weeks#closed',      as: :closed,        via: 'get'
  match 'weeks/final/:id',      to: 'weeks#final',       as: :final,         via: 'get'
  match 'weeks/auto_create',    to: 'weeks#auto_create', as: :auto_create,   via: 'get'
  match 'weeks/add_scores/:id', to: 'weeks#add_scores',  as: :add_scores,    via: 'get'
  match 'seasons/open/:id',     to: 'seasons#open',      as: :season_open,   via: 'get'
  match 'seasons/closed/:id',   to: 'seasons#closed',    as: :season_closed, via: 'get'
  resources :seasons, shallow: :true do
    resources :weeks
  end
  resources :weeks, only: [:edit, :update, :show, :destroy]

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
