Rails.application.routes.draw do
  devise_for :users, skip: :all
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :accounts, only: [:create, :show, :destroy] do
    resource :name, only: [:update]
    resource :password, only: [:update]
    resource :email, only: [:update]
  end
end
