Rails.application.routes.draw do
  root "dashboard#index"
  
  resources :beneficiari do
    resources :procedimenti do
      resources :udienze
      resources :scadenze
      resources :rendiconti
      resources :attivita
    end
  end
  
  resources :scadenze, only: [:index]
  resources :udienze, only: [:index]
  
  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
