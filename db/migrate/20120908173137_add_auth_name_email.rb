class AddAuthNameEmail < ActiveRecord::Migration
  def change
    add_column :authentications, :first_name, :string
    add_column :authentications, :last_name, :string
    add_column :authentications, :email, :string
  end
end
