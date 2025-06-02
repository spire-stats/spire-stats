Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "run_files/new" => "run_file#new"
  get "run_files" => "run_file#index"
  post "run_files" => "run_file#create"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Statistics routes
  get "statistics" => "statistics#index", as: :statistics
  get "statistics/cards" => "statistics#cards", as: :cards_statistics
  get "statistics/card/:id" => "statistics#card", as: :card_statistics
  get "statistics/relics" => "statistics#relics", as: :relics_statistics
  get "statistics/relic/:id" => "statistics#relic", as: :relic_statistics
  get "statistics/encounters" => "statistics#encounters", as: :encounters_statistics

  get "stats" => "stats#index", as: :stats

  root "statistics#index"
  resources :runs, only: [ :index, :show ]

  authenticate :user, ->(user) { user.admin? } do
    mount PgHero::Engine, at: "pghero"
  end
end
