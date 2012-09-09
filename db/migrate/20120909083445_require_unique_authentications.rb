class RequireUniqueAuthentications < ActiveRecord::Migration
  def up
    add_index "authentications", ["provider","uid"], :name => "index_authentications_on_uid", :unique => true
  end

  def down
    remove_index "authentications", :name => "index_authentications_on_uid"
  end
end
