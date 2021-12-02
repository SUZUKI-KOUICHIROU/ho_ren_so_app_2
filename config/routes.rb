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

  resources :users, only: %i[index  show], module: 'users'

  resources :users, only: %i[edit] do
    scope module: :projects do
      resources :projects do
        resources :messages do
          member do
            patch 'read'
          end
        end
        resources :counselings do
          member do
            patch 'read'
          end
        end
        resources :reports
      end
    end
  end

  scope module: :formats do
    get 'projects/:project_id/report_formats/edit', to: 'report_formats#edit', as: :edit_project_report_format
    get 'projects/:project_id/report_formats/new', to: 'report_formats#new', as: :new_project_report_format
    post 'project/:project_id/report_formats/create', to: 'report_formats#create', as: :create_project_report_format
    patch 'projects/:project_id/report_formats/update', to: 'report_formats#update', as: :update_project_report_format
    get 'input_forms/replacement_input_forms', to: 'report_formats#replacement_input_forms', as: :replacement_input_forms
    delete 'projects/:project_id/form_display_order/:form_display_order_id/report_formats/destroy', to: 'report_formats#destroy', as: :destroy_project_report_format
  end

  scope module: :projects do
    get 'projects/:project_id/users/:user_id/invitations/new', to: 'invitations#new', as: :new_invitation
    post 'projects/:project_id/users/:user_id/invitations/create', to: 'invitations#create', as: :create_invitation
  end

end
