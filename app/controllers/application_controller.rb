class ApplicationController < ActionController::Base
  include Internationalization
  include ErrorHandling

  before_action :authenticate_user!, unless: :devise_controller?

  def after_sign_in_path_for(*)
    reports_path
  end

  def after_sign_out_path_for(*)
    user_session_path
  end
end
