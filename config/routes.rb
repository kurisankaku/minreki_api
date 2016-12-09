Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_scope :user do
    resources :accounts, only: [:create, :show, :destroy] do
      resource :name, only: [:update]
      resource :password, only: [:update]
      resource :email, only: [:update]
    end

    resource :confirmation, only: [:show]
    post :login, to: "login#create", as: "login"
  end
  devise_for :users, skip: :all, failure_app: "Authenticate::FailureAppController"
end
