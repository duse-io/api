class CreateSecrets < ActiveRecord::Migration
  def change
    create_table :secrets do |t|
      t.string :title
      t.text :cipher_text
      t.string :last_edited_by_id
    end
  end
end

