class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    redirect = params["redirect"] && CGI::unescape(params["redirect"])
    logger.info "redirect after sign_out: " + redirect.to_s
    redirect ? redirect : root_path
  end
end
