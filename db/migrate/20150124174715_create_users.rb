class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, null: false, default: ''
      t.string :email,    null: false, default: ''
      t.string :password_digest, null: false
      t.string :confirmation_token
      t.timestamp :confirmed_at
      t.string :type
      t.text   :public_key
      t.text   :private_key
    end

    add_index :users, :username, unique: true
    add_index :users, :email,    unique: true
    add_index :users, :confirmation_token, unique: true
  end
end

