class Authentication < ActiveRecord::Base
  belongs_to :user
  attr_accessible :provider, :uid, :first_name, :last_name, :email
end
