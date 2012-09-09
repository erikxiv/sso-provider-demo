class RegistrationsController < Devise::RegistrationsController
  def new
    logger.info "REGISTRATION.NEW"
     # Building the resource with information that MAY BE available from omniauth!
     build_resource(:first_name => session[:omniauth] && session[:omniauth]['user_info'] && session[:omniauth]['user_info']['first_name'],
         :last_name => session[:omniauth] && session[:omniauth]['user_info'] && session[:omniauth]['user_info']['last_name'],
         :email => session[:omniauth_email] )
     render :new
  end

  def create
    logger.info "REGISTRATION.CREATE"
    build_resource

    if session[:omniauth] && @user.errors[:email][0] =~ /has already been taken/
      user = User.find_by_email(@user.email)
      # Link Accounts - if via social connect
      return redirect_to link_accounts_url(user.id)
    end

    # normal processing
    super
    session[:omniauth] = nil unless @user.new_record?
  end

  def build_resource(*args)
    logger.info "REGISTRATION.build_resource"
    super

    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
    end
  end

  def after_update_path_for(scope)
    logger.info "REGISTRATION.AFTER_UPDATE_PATH_FOR"
    session[:referrer] ? session[:referrer] : root_path
  end
end