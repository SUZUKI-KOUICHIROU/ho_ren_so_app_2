Rails.application.routes.draw do

  # :moduleオプションを使用して「コントローラ#アクション」のみにstatic_pages名前空間を追加
  scope module: :static_pages do
    root 'static_pages#new'
  end
  
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations'
  }

  #devise_for :users, :controllers => {
    #:registrations => 'users/registrations',
    #:sessions => 'users/sessions'
  #}

  devise_scope :user do
    get 'users/signup', to: 'users/registrations#new'
    get 'users/login', to: 'users/sessions#new'
    delete 'users/logout', to: 'users/sessions#destroy'
    resources :users
  end

  namespace :users do
    resources :users, only: %i[index show] do
      resources :projects
    end
  end
<<<<<<< HEAD
=======

>>>>>>> 8d7b6c3ffba21fe75149bc288758527089441853
end
