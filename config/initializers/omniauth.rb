Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV["TWITTER_APP_ID"], ENV["TWITTER_APP_SECRET"]
  provider :facebook, ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"]
  provider :linkedin, ENV["LINKEDIN_APP_ID"], ENV["LINKEDIN_APP_SECRET"]
  provider :google_oauth2, ENV["GOOGLE_OAUTH2_APP_ID"], ENV["GOOGLE_OAUTH2_APP_SECRET"], { access_type: "offline", approval_prompt: "" }
end
