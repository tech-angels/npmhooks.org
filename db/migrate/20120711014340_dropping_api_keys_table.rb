class DroppingApiKeysTable < ActiveRecord::Migration
  def change
    drop_table :api_keys
    change_table :users do |t|
      t.string :api_key, :limit => 32
    end
  end
end
