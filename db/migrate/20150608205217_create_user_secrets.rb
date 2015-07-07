class CreateUserSecrets < ActiveRecord::Migration
  def change
    create_table :user_secrets do |t|
      t.integer :user_id, index: true
      t.integer :secret_id, index: true
      t.integer :folder_id, index: true

      t.timestamps null: false
    end
  end
end
