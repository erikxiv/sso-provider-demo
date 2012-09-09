class User < ActiveRecord::Base
  has_many :authentications, :dependent => :delete_all
  has_many :access_grants, :dependent => :delete_all

  before_validation :initialize_fields, :on => :create

  devise :token_authenticatable,
         :timeoutable, :trackable, :rememberable, :omniauthable

  self.token_authentication_key = "oauth_token"

  attr_accessible :email, :remember_me, :first_name, :last_name

  def password_required?
    false
  end
  
  def apply_omniauth(omniauth)
    authentications.build(
      :provider => omniauth["provider"], 
      :uid => omniauth["uid"],
      :first_name => omniauth["first_name"],
      :last_name => omniauth["last_name"],
      :email => omniauth["email"])
    self.first_name ||= omniauth["first_name"]
    self.last_name ||= omniauth["last_name"]
    self.email ||= omniauth["email"]
    self
  end

  def self.find_for_token_authentication(conditions)
    where(["access_grants.access_token = ? AND (access_grants.access_token_expires_at IS NULL OR access_grants.access_token_expires_at > ?)", conditions[token_authentication_key], Time.now]).joins(:access_grants).select("users.*").first
  end
  
  def initialize_fields
    self.status = "Active"
    self.expiration_date = 1.year.from_now
  end
end
