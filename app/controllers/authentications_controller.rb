require 'pp'

class AuthenticationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:create, :link, :new]

  def index
  end
  
  # Create a new user and a new authentication
  def new
    # Verify that the user is logged in via at least one provider
    if !session["oauth"].values.empty?
      user = User.new
      # Build authentications for all currently logged in providers
      session["oauth"].values.each{|a| user.apply_omniauth(a)}
      if user.save
        flash[:notice] = "Successfully registered"
        sign_in_and_redirect(:user, user)
      else
        flash[:notice] = "Oops. Unfortunately we failed to register your new account."
      end
    end

    redirect_to root_path
  end
  
  def link
    # Get all e-mails from currently logged in oauth sessions
    emails = session["oauth"].values.map{|p| p["email"]}.keep_if{|e| e && e.length>0}.uniq
    # Create a dummy user to display name
    @user = User.new
    @user.apply_omniauth(session["oauth"].values.first)
    # Get all authentications matching signed in e-mails
    @matches = Authentication.where(:email => emails)
  end

  # Callback from oauth login
  # If an existing account is found, sign the user in
  # If not, ask if the user wants to create a new account or link to another credential
  def create
    omniauth = request.env['omniauth.auth']
    logger.info omniauth.pretty_inspect
    # Store oauth details in session
    session["oauth"] ||= {} 
    session["oauth"][omniauth.provider] = {
      "uid" => omniauth.uid,
      "provider" => omniauth.provider,
      "first_name" => omniauth.info.first_name || omniauth.info.name.split(" ").first,
      "last_name" => omniauth.info.last_name || omniauth.info.name.split(" ").last,
      "email" => omniauth.info.email,
      "token" => omniauth.credentials.token,
      "secret" => omniauth.credentials.secret,
      "status" => "active"
    }
    # Check if the credentials are in the database
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

    # Are we already logged in?
    if current_user
      # Is this an old credential?
      if authentication
        flash[:notice] = "Signed in successfully via " + omniauth['provider']
        # Log in to this provider as well (e.g. no action)
        redirect_to root_path
      else
        # Link the new credential to this account
        current_user.apply_omniauth(session["oauth"][omniauth.provider])
        current_user.save
        flash[:notice] = "Linked " + omniauth['provider'] + " credentials to account"
        redirect_to root_path
      end
    # If we are not logged in, do we recognize the credentials?
    elsif authentication
      flash[:notice] = "Signed in successfully"
      # Retrieve all credentials linked to this account
      authentications = authentication.user.authentications.find(:all)
      # Check if we have any oauth credentials not yet saved to this account
      session["oauth"].values.each{ |p|
        a = authentications.reject{|a| a.provider != p["provider"]}.first
        logger.info "SAVE ONLY NEW? " + p["provider"] + ":" + (a ? "no" : "yes")
        authentication.user.apply_omniauth(p).save unless a
      }
      # Load session parameters for not logged in credentials
      logger.info "Loading inactive credentials..." + authentications.length.to_s
      authentications.each { |a|
        p = session["oauth"].values.reject{|p| a.provider != p["provider"]}.first
        logger.info "LOAD MISSING? " + a.provider + ":" + (p ? "no": "yes")
        if !p
          session["oauth"][a.provider] = {
            "uid" => a.uid,
            "provider" => a.provider,
            "first_name" => a.first_name,
            "last_name" => a.last_name,
            "email" => a.email,
            "status" => "inactive"
          }
        end
      }
      sign_in_and_redirect(:user, authentication.user)
    # We are not logged in and we do not recognize the credentials. Ask if the user wants to create a new account
    else
      user = User.new
      user.apply_omniauth(session["oauth"][omniauth.provider])
      return redirect_to link_accounts_url(0)
    end
  end

  def failure
    flash[:error] = params[:message]
    redirect_to root_path
  end

  def destroy
    @authentication = Authentication.find(params[:id])
    @authentication.destroy

    respond_to do |format|
      format.html { redirect_to(authentications_url) }
      format.xml  { head :ok }
    end
  end
end
