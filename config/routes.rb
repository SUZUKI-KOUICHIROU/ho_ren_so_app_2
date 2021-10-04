Rails.application.routes.draw do

  # トップページのパスを指定(static_pages/static_pages#new)
  # :moduleオプションを使用して「コントローラ#アクション」のみにstatic_pages名前空間を追加
  # scope module: :static_pages do
  #   root 'static_pages#new'
  # end

  # Deviseのログイン画面をrootに設定、そのままだと設定できないので、devise＿scopeを使用
  devise_scope :user do
    root to: 'users/sessions#new'
  end

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    passwords: 'users/passwords',
    registrations: 'users/registrations'
  }

  scope module: :users do
    resources :users, only: %i[index show]
  end

  resources :users do
    scope module: :projects do
      resources :projects do
        resources :messages  
      end
    end
  end
end
