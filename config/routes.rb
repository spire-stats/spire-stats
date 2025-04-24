Rails.application.routes.draw do
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

  # Defines the root path route ("/")
  root "run_file#index"

  resources :runs, only: [ :index, :show ]

  authenticate :user, ->(user) { user.admin? } do
    mount PgHero::Engine, at: "pghero"
  end
end
