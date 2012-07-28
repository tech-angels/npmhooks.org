class UsersGithubUid < ActiveRecord::Migration
  def change
    rename_column :users, :uid, :github_uid
    remove_column :users, :provider
  end
end
