# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  protect_from_forgery
  before_action :configure_permitted_parameters, if: :devise_controller?
  prepend_before_action :require_no_authentication, only: [:cancel]
  prepend_before_action :authenticate_scope!, only: %i[update destroy edit]
  prepend_before_action :set_minimum_password_length, only: %i[new edit]
  # before_action :creatable?, only: [:new, :create]
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  def create
    @user = User.new(sign_up_params)
    pp @user
    render :new and return if params[:back]

    super
  end

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
  protected

  # ユーザー新規登録後のリダイレクト先を参加しているプロジェクト一覧ページに変更
  def after_sign_up_path_for(resource)
    user_projects_path(resource)
  end

  # ユーザー編集後のリダイレクト先をユーザー詳細ページに変更
  def after_update_path_for(resource)
    user_path(resource)
  end

  def update_resource(resource, params)
    params[:has_editted] = true # ユーザー情報に変更があったフラグをTRUEに
    resource.update_without_current_password(params)
  end

  # ユーザー新規登録の際にパラメーターを追加(user_nameを追加)
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:user_name, :has_editted])
    devise_parameter_sanitizer.permit(:account_update, keys: [:user_name, :has_editted])
  end
end
