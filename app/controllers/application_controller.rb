class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :current_session
  before_filter :user_required, :session_required, :confirmed_session_required
  
  private
    def current_user
      @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
      session[:user_id] = nil unless @current_user
      @current_user
    end
    
    def current_session
      @current_session ||= Session.find_by_id(session[:user_session_id])
      session[:user_session_id] = nil unless @current_session
      @current_session
    end
    
    def user_required
      redirect_to :new_session unless current_user
    end
    
    def session_required
      redirect_to :track_sessions unless current_session
    end
    
    def confirmed_session_required
      redirect_to confirm_session_url(current_session), 
        :alert => "This device is not recognised" unless current_session.confirmed?
    end
end
