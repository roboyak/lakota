Rails.application.routes.draw do
  namespace :admin do
    resources :policies

    root to: "policies#index"
  end
  resources :policies, only: [:index]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
