Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_scope :user do
    resources :accounts, only: [:create, :show, :destroy] do
      resource :name, only: [:update]
      resource :password, only: [:update]
      resource :email, only: [:update]
    end
  end
  devise_for :users, only: :confirmation, controllers: { confirmations: 'accounts/confirmations'}
end
