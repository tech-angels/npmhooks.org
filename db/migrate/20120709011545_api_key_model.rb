class ApiKeyModel < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.integer  "user_id"
      t.string   "api_key",    :limit => 32
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end
  end
end
