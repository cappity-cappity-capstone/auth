class AddUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false

      t.string :password_salt, null: false
      t.string :password_hash, null: false

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
