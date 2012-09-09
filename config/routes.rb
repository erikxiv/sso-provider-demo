OauthProviderDemo::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => 'registrations',
                                       :sessions => 'sessions'}
  # omniauth client stuff
  match '/auth/:provider/callback', :to => 'authentications#create'
  match '/auth/failure', :to => 'authentications#failure'

  # Provider stuff
  match '/auth/oauth_demo/authorize' => 'auth#authorize'
  match '/auth/oauth_demo/access_token' => 'auth#access_token'
  match '/auth/oauth_demo/user' => 'auth#user'
  match '/oauth/token' => 'auth#access_token'

  # Account linking
  match 'authentications/:user_id/link' => 'authentications#link', :as => :link_accounts
  match 'authentications/:user_id/add' => 'authentications#add', :as => :add_account
  match 'authentications/new' => 'authentications#new', :as => :new_account
  
  # Explicit sign out needed for some reason
  devise_scope :user do
    delete "sessions/destroy", :to => "devise/sessions#destroy"
  end
  
  # Welcome page
  root :to => 'authentications#index'
end
