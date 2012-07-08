class UserAddEmail < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :name, :login
      t.string :email
    end
  end
end
