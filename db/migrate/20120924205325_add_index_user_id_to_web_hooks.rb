class AddIndexUserIdToWebHooks < ActiveRecord::Migration
  def change
    add_index :web_hooks, :user_id
  end
end
