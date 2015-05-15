class CreateSecrets < ActiveRecord::Migration
  def change
    create_table :secrets do |t|
      t.string :title
      t.text :cipher_text
      t.integer :last_edited_by_id, index: true
    end
  end
end

