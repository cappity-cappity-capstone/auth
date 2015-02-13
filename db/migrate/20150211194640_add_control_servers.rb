class AddControlServers < ActiveRecord::Migration
  def change
    create_table :control_servers do |t|
      t.string :uuid, null: false
      t.string :ip, null: false
      t.integer :port, null: false

      t.timestamps null: false
    end

    add_index :control_servers, :uuid, unique: true

    add_column :users, :control_server_id, :integer
    add_index :users, :control_server_id
    add_foreign_key :users, :control_servers, column: :control_server_id
  end
end
