Rails.application.routes.draw do

  root 'static_pages#top'
  
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations'
  }
  
  devise_scope :user do
    get 'users/signup', to: 'users/registrations#new'
    get 'users/login', to: 'users/sessions#new'
    delete 'users/logout', to: 'users/sessions#destroy'
    resources :users
  end

end
