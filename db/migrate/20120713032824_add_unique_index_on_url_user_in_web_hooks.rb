class AddUniqueIndexOnUrlUserInWebHooks < ActiveRecord::Migration
  def change
    add_index :web_hooks, [:user_id, :url], :unique => true
  end
end
