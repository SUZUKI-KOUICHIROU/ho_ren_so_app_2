# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  prepend_before_action :require_no_authentication, only: %i[new create]
  prepend_before_action :set_minimum_password_length, only: %i[new edit]
  # before_action :creatable?, only: [:new, :create]
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :success, :signed_out if signed_out
    yield if block_given?
    respond_to_on_destroy
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  end

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

  def auth_options
    { scope: resource_name, recall: "#{controller_path}#new" }
  end

  # ユーザー新規登録後のリダイレクト先を参加しているプロジェクト一覧ページに変更
  #def after_sign_in_path_for(resource)
    #user_projects_path(resource)
  #end

  def after_sign_in_path_for(resource)
    stored_location = session[:user_return_to]
    session.delete(:user_return_to)
    
    if stored_location && user_has_access?(resource, stored_location)
      stored_location
    else
      user_projects_path(resource)
    end
  end
end
