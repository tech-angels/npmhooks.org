class AddIndexesToUsers < ActiveRecord::Migration
  def change
    add_index :users, :github_uid, unique: true
    add_index :users, :api_key, unique: true
  end
end
