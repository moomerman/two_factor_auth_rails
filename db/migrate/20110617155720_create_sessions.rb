class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.references :user
      
      t.string   :client_id, :null => false
      t.string   :ip_address, :null => false
      t.string   :user_agent
      t.integer  :login_count, :null => false, :default => 0
      
      t.string   :unique_key
      t.datetime :unique_key_generated_at
      
      t.integer  :confirmation_failure_count, :null => false, :default => 0
      t.datetime :client_confirmed_at
      t.datetime :authenticated_at
      t.datetime :finished_at
      
      t.timestamps
    end
    add_index :sessions, [:user_id, :client_id], :unique => true
  end
end
