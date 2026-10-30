Rails.application.routes.draw do
  root "dashboard#index"

  resource :session, only: %i[new create destroy]
  resource :password, only: %i[edit update]
  resources :users, only: %i[index new create edit update]

  resources :beneficiari do
    resources :contatti, only: %i[new create edit update destroy]
    resources :conti, except: :index do
      resources :movimenti, only: %i[new create edit update destroy]
    end
    resources :procedimenti, except: :index do
      resources :udienze, :scadenze, :attivita, :istanze, only: %i[new create edit update destroy]
      resources :rendiconti, except: :index do
        post :ricalcola, on: :member
      end
      resources :documenti, except: :index
    end
  end

  resources :scadenze, only: :index
  resources :udienze, only: :index

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
