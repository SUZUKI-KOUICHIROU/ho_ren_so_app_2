Rails.application.routes.draw do

  # :moduleオプションを使用して「コントローラ#アクション」のみにstatic_pages名前空間を追加
  scope module: :static_pages do
    root 'static_pages#new'
  end

  devise_for :users, :controllers => {
    :registrations => 'users/registrations',
    :sessions => 'users/sessions'
  }

  devise_scope :user do
    get "user/:id", :to => "users/registrations#detail"
    get "signup", :to => "users/registrations#new"
    get "login", :to => "users/sessions#new"
    get "logout", :to => "users/sessions#destroy"
  end

  namespace :users do
    resources :users, only: %i[index show] do
      resources :projects
    end
  end
end
