class WebHookModel < ActiveRecord::Migration
  def change
    create_table :web_hooks do |t|
      t.integer  "user_id"
      t.string   "url"
      t.integer  "failure_count", :default => 0
      t.datetime "created_at",                   :null => false
      t.datetime "updated_at",                   :null => false
    end
  end
end
