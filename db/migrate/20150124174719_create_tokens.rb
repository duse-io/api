class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :token_hash
      t.integer :user_id
      t.timestamp :last_used_at
    end

    add_index :tokens, :token_hash, unique: true
  end
end

