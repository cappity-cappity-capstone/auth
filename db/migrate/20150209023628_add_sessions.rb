class AddSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :key, null: false
      t.datetime :expires_on, null: false
      t.integer :user_id, null: false

      t.timestamps null: false
    end

    add_foreign_key :sessions, :users, column: :user_id
    add_index :sessions, :user_id
  end
end
