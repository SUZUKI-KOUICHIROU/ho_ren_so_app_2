class ApplicationController < ActionController::Base
  before_action :store_user_location!, if: :storable_location?

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

  def storable_location?
    request.get? && !devise_controller? && !request.xhr? && root_path.exclude?('/users')
  end

  def store_location_for(resource_or_scope, location)
    session[:"#{resource_or_scope}_return_to"] = location
  end

  def user_has_access?(user, path)
    counseling_id = extract_counseling_id_from_path(path)
    return false unless counseling_id

    counseling = Counseling.find_by(id: counseling_id)
    return false unless counseling

    counseling.project.users.include?(user)
  end

  def extract_counseling_id_from_path(path)
    match = path.match(/counselings\/(\d+)/)
    match[1] if match
  end

  # ログアウト後のリダイレクト先を指定
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
