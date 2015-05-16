class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :token_hash
      t.string :type
      t.belongs_to :user
      t.timestamp :last_used_at
    end

    add_index :tokens, :token_hash, unique: true
  end
end

