class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, null: false, default: ''
      t.string :password_digest, null: false
      t.string :type
      t.text   :public_key
      t.text   :private_key
    end

    add_index :users, :username, unique: true
  end
end
