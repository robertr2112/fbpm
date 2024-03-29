
Rails.application.routes.draw do

  resources :users
  resources :teams, only: [:edit, :update, :index, :show]
  resources :password_resets

  # Static routes
  #root 'seasons#index' # Temporary root page
  root  'static_pages#home'
  get    '/signup',             to: 'users#new'
  get    '/login',              to: 'sessions#new'
  post   '/login',              to: 'sessions#create'
  delete '/logout',             to: 'sessions#destroy'
  match '/help',              to: 'static_pages#help',            via: 'get'
  match '/about',             to: 'static_pages#about',           via: 'get'
  match '/contact',           to: 'static_pages#contact',         via: 'get'
  match 'users/admin_add/:id', to: 'users#admin_add',
                       as: :admin_add,     via: 'get'
  match 'users/admin_del/:id', to: 'users#admin_del',
                       as: :admin_del,     via: 'get'
  match 'users/resend_activation/:id', to: 'users#resend_activation',
                       as: :resend_activation, via: 'get'


  # Diagnostics paths
  match 'pools/diagnostics/:id',   to: 'pools#pool_diagnostics',   as: :pool_diagnostics,    via: 'get'
  match 'pools/diag_chg/:id',      to: 'pools#pool_diag_chg', as: :pool_diag_chg,    via: 'get'
  match 'seasons/diagnostics/:id', to: 'seasons#season_diagnostics',   as: :season_diagnostics,    via: 'get'
  match 'seasons/diag_chg/:id',    to: 'seasons#season_diag_chg', as: :season_diag_chg,    via: 'get'

  # Seasons and weeks paths
  match 'weeks/open/:id',        to: 'weeks#open',         as: :open,           via: 'get'
  match 'weeks/closed/:id',      to: 'weeks#closed',       as: :closed,         via: 'get'
  match 'weeks/final/:id',       to: 'weeks#final',        as: :final,          via: 'get'
  match 'weeks/auto_create/:id', to: 'weeks#auto_create',  as: :auto_create,    via: 'get'
  match 'weeks/update_games/:id',to: 'weeks#update_games', as: :update_games,   via: 'get'
  match 'weeks/add_scores/:id',  to: 'weeks#add_scores',   as: :add_scores,     via: 'get'
  match 'seasons/open/:id',      to: 'seasons#open',       as: :season_open,    via: 'get'
  match 'seasons/closed/:id',    to: 'seasons#closed',     as: :season_closed,  via: 'get'
  resources :seasons, shallow: :true do
    resources :weeks
  end

  # Pools and Pool Messages routes
  match 'pools/join/:id',     to: 'pools#join',    as: :join,     via: 'get'
  match 'pools/leave/:id',    to: 'pools#leave',   as: :leave,    via: 'get'
  match 'pools/my_pools',     to: 'pools#my_pools',as: :my_pools, via: 'get'
  match 'pools/:id/invite',   to: 'pool_messages#invite',  as: :invite,   via: 'get'
  match 'pools/:id/send_invite',   to: 'pool_messages#send_invite',  as: :send_invite,   via: 'post'
  resources :pools do
    resources :entries, only: [:new, :create]
    resources :pool_messages, only: [:new, :create]
  end

  resources :entries, only: [:edit, :update, :destroy] do
    resources :picks, only: [:new, :create]
  end

  resources :weeks, only: [:edit, :update, :show, :destroy]
  resources :picks, only: [:edit, :update, :destroy]
  resources :account_activations, only: [:edit]

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
