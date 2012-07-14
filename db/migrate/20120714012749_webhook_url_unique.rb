class WebhookUrlUnique < ActiveRecord::Migration
  def change
    remove_index :web_hooks, :name => :index_web_hooks_on_user_id_and_url
    add_index :web_hooks, :url, :unique => true
  end
end
