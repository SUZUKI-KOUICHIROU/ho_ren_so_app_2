Rails.application.routes.draw do

  #root 'static_pages#top'
  
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    users: 'users/users'
  }
  
  # :moduleオプションを使用して「コントローラ#アクション」のみにstatic_pages名前空間を追加
  scope module: :static_pages do
    root 'static_pages#new'
  end

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

end
