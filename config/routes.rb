Rails.application.routes.draw do
  if Rails.env.development? || Rails.env.production?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  # post "/graphql", to: "graphql#execute"
  match "/graphql", to: "graphql#execute", via: [ :get, :post ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  # API Routes
  namespace :api do
    namespace :v1 do
      # Authentication routes
      post 'auth/send-otp', to: 'auth#send_otp'
      post 'auth/verify-otp', to: 'auth#verify_otp'
      post 'auth/refresh-token', to: 'auth#refresh_token'
      post 'auth/logout', to: 'auth#logout'

      # User profile routes
      get 'users/me', to: 'users#show'
      put 'users/me', to: 'users#update'

      # Menu routes (cached from Rista)
      get 'menu', to: 'menu#index'
      post 'menu/sync', to: 'menu#sync'
      get 'menu/sync_status', to: 'menu#sync_status'

      # Orders (user history + create, proxied to Rista)
      resources :orders, only: [:index, :show, :create]

      # Stores
      resources :stores, only: [ :index, :show ]
      resources :menu_items, only: [ :show ]

      # Admin utilities
      get 'admin/fix-data', to: 'admin#fix_data'
      get 'admin/debug-env', to: 'admin#debug_env'
      get 'admin/test-rista', to: 'admin#test_rista'
    end
  end
end
