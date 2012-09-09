class RemovePasswordRequirement < ActiveRecord::Migration
  def up
    remove_column :users, :encrypted_password
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    change_column :users, :email, :string, :null => true
  end

  def down
  end
end
