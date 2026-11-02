Rails.application.routes.draw do
  devise_for :users

  root to: 'dashboard#index'

  get 'files/:id', to: 'files#show', as: :file

  # Notifications
  resources :notifications, only: [:index, :destroy] do
    member do
      patch :mark_as_read
    end
    collection do
      patch :mark_all_as_read
    end
  end

  resources :beneficiaries do
    resources :appointments,   shallow: true
    resources :reports,        shallow: true do
      resources :income_entries,  shallow: true
      resources :expense_entries, shallow: true
      member do
        post  :generate_pdf
        patch :update_status
      end
    end
    resources :assets, path: 'patrimony', shallow: true
    resources :properties,     shallow: true
    resources :liabilities,    shallow: true
    resources :recurring_incomes, shallow: true do
      member do
        patch :toggle_active
      end
    end
    resources :recurring_expenses, shallow: true do
      member do
        patch :toggle_active
      end
    end
    resources :deadlines,      shallow: true
    resources :hearings,       shallow: true
    resources :documents,      shallow: true
    resources :communications, shallow: true
    resources :contacts,       shallow: true
    member do
      post :generate_asset_inventory
      get  :download_asset_inventory
    end
  end

  resources :deadlines, only: [:index]

  get 'calendar', to: 'deadlines#calendar'

  namespace :exports do
    get :report_pdf,  defaults: { format: :pdf }
    get :asset_pdf,   defaults: { format: :pdf }
    get :entries_csv, defaults: { format: :csv }
  end

  get "up" => "rails/health#show", as: :rails_health_check
end