class ApplicationController < ActionController::Base
    #before_filter :configure_permitted_parameters, if: :devise_controller?

    protected

    def configure_permitted_parameters
        devise_parameter_sanitizer.for(:sign_up) 
        devise_parameter_sanitizer.for(:sign_in) 
        devise_parameter_sanitizer.for(:account_update) 

        # :inviteと:accept_invitationに:usernameを許可する
        devise_parameter_sanitizer.for(:invite) { |u| u.permit(:email, :username) }
        devise_parameter_sanitizer.for(:accept_invitation) { |u| u.permit(:password, :password_confirmation, :invitation_token, :user_name) }
    end

end
