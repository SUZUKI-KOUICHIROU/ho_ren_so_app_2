require 'sidekiq/web'

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
        collection do
          get 'reports/all_project_reporting_rate', as: :all_project_reporting_rate
        end
        get 'new_period'
        get 'notice_not_submitted_members'
        get 'reports/view_reports_log'
        get 'reports/view_reports_log_month'
        resources :messages do
          member do
            patch 'read'
          end
          collection do
            get 'history'
          end
          resources :message_replys, only: %i[edit create update destroy] do
            member do
              get 'cancel'
              get 'show_image'
              delete 'delete_image'
            end
          end
        end
        resources :counselings do
          member do
            patch 'read'            
          end
          resources :counseling_replys, only: %i[edit  create update destroy] do
            member do
              get 'cancel'
              get 'show_image'
              delete 'delete_image'
            end
          end
        end
        resources :reports do
          member do
            post 'reject'
            post 'resubmitted'
          end
          collection do
            get 'history'
          end
          resources :report_replys, only: %i[edit  create update destroy] do
            member do
              get 'cancel'
              get 'show_image'
              delete 'delete_image'
            end
          end
        end
      end
    end
  end

  scope module: :formats do
    get 'users/:user_id/projects/:project_id/report_formats/edit', to: 'report_formats#edit', as: :edit_project_report_format
    get 'users/:user_id/projects/:project_id/report_formats/new', to: 'report_formats#new', as: :new_project_report_format
    post 'users/:user_id/projects/:project_id/report_formats/create', to: 'report_formats#create', as: :create_project_report_format
    patch 'users/:user_id/projects/:project_id/report_formats/update', to: 'report_formats#update', as: :update_project_report_format
    get 'input_forms/replacement_input_forms', to: 'report_formats#replacement_input_forms', as: :replacement_input_forms
    delete 'projects/:project_id/question/:question_id/report_formats/destroy', to: 'report_formats#destroy', as: :destroy_project_report_format
  end

  scope module: :projects do
    get 'join', to: 'members#join'
    get 'input_forms/frequency_input_form_switching', to: 'projects#frequency_input_form_switching', as: :frequency_input_form_switching
    get 'report_forms/report_form_switching', to: 'reports#report_form_switching', as: :report_form_switching
    get 'users/:user_id/projects/:project_id/index', to: 'members#index', as: :project_member_index
    delete 'users/:user_id/project/:project_id/member_destroy', to: 'members#destroy', as: :project_member_destroy
    post 'users/:user_id/project/:project_id/delegate_leader/:to', to: 'members#delegate', as: :delegate_leader # リーダー権限委譲リクエストの発行
    post 'users/:user_id/project/:project_id/cancel_delegate/:delegate_id', to: 'members#cancel_delegate', as: :cancel_delegate # リーダー権限委譲リクエストのキャンセル
    post 'users/:user_id/project/:id/accept/:delegate_id', to: 'projects#accept_request', as: :accept_request # リーダー権限委譲に対する受認
    post 'users/:user_id/project/:id/disown/:delegate_id', to: 'projects#disown_request', as: :disown_request # リーダー権限委譲に対する辞退
    get 'users/:user_id/setting', to: 'members#setting', as: :setting           # 設定ページ表示
    patch 'users/:user_id/set_admin/:admin_id', to: 'members#set_admin', as: :set_admin   # 管理者権限変更
  end

  get 'index/index_switching', to: 'base#index_switching', as: :index_switching

  scope module: :users do
    get 'users/:user_id/projects/:project_id/invitations/new', to: 'invitations#new', as: :new_invitation
    post 'users/:user_id/projects/:project_id/invitations/create', to: 'invitations#create', as: :create_invitation
  end

  # 報告リマインド用アクションを追加
  post '/projects/members/send_reminder', to: 'projects/members#send_reminder' # 報告リマインドを設定
  post '/projects/members/reset_reminder', to: 'projects/members#reset_reminder' # 報告リマインド設定をリセット

  #letter_openerを追加
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # 管理者ユーザーのみ、Sidekiqダッシュボードにアクセス可能とする
  authenticate :user, lambda { |u| u.admin? } do
    # Sidekiqダッシュボードをマウント
    mount Sidekiq::Web => '/sidekiq'
  end
  # 管理者以外がSidekiqダッシュボードにアクセスした場合は、rootへリダイレクトする
  get '/sidekiq', to: redirect('/')

end
