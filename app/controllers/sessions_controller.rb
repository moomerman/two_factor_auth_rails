class SessionsController < ApplicationController
  skip_before_filter :user_required, :only => [:new, :create]
  skip_before_filter :session_required, :only => [:new, :track, :create, :finish]
  skip_before_filter :confirmed_session_required
  
  def new
    reset_session
    @session = Session.new
  end
  
  def create
    reset_session
    @session = Session.new(params[:session])
    
    if @session.authentic?
      session[:user_id] = @session.user.id
      redirect_to :track_sessions, :notice => "Welcome back"
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end
  
  def finish
    current_session.finish! if current_session
    reset_session
    redirect_to :root, :notice => "Logged out!"
  end
  
  def destroy
    @session.destroy
    redirect_to :root
  end
  
  def track
    Session.perform_housekeeping
    
    # assign a new id for this client if it isn't recognised
    client_id = cookies.signed[:_client_id] ||= UUIDTools::UUID.timestamp_create.to_s
    @session = Session.find_or_initialize_by_user_id_and_client_id(current_user.id, client_id)
    
    # check if we have already authenticated this session
    redirect_to params[:next] || :root and return if @session == current_session
    
    @session.update_attributes(
      :ip_address => request.remote_ip,
      :user_agent => request.user_agent,
      :client_id =>  client_id,
      :login_count => @session.login_count + 1,
      :authenticated_at => Time.now.utc,
      :finished_at => nil
    )
    
    # sign up session is trusted
    @session.confirm! if session[:first_visit]
    
    session[:user_session_id] = @session.id
    
    # remember this client
    cookies.permanent.signed[:_client_id] = {
      :value => @session.client_id, 
      :secure => Rails.env.production? ? true : false,
      :httponly => true
    }
    
    @session.send_confirmation_code unless @session.confirmed?
    
    flash.keep # pass on any flash messages
    redirect_to params[:next] || :root
  end
  
  def confirm
  end
  
  def validate
    @session.validation_code = params[:session][:validation_code]
    if @session == current_session and @session.validates?
      @session.confirm!
      redirect_to :root, :notice => 'This device is now validated'
    else
      @session.increment! :confirmation_failure_count
      if @session.too_many_failures?
        @session.send_confirmation_code
        flash[:alert] = "Too many validation failures. We've sent you another code."
      end
      redirect_to :action => :confirm
    end
  end
  
  def resend
    @session.send_confirmation_code
    redirect_to :action => :confirm, :notice => 'A new code has been sent'
  end
  
  private
    def session_required
      @session = current_user.sessions.find_by_id(params[:id])
      redirect_to :root unless @session
    end
end