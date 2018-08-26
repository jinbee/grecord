Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'records#index'
  #resources :sessions, only: [:new, :create, :destroy ,:signup]
  resources :budgets do
    collection do
      get :list
    end
  end
  resources :sgames do
    member do
      get :toggle
    end 
  end
  
  resources :users do
    collection do
      post :signup
      get :signup
      get :info

    end 
    member do
      get :editpw
      post :updatepw
    end 
  end
  
  resources :sessions do
    collection do
      post :signup
      get :signup
    end 
  end
  
  resources :records do
    collection do
      post :confirm
      get :confirm
      get :mypage
      get :event
      get :list
      post :list
      get :detail
      get :monthinfo
    end
    member do

    end 
  end
end
