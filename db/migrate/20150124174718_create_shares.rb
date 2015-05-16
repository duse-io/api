class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.text :content
      t.text :signature
      t.belongs_to :user
      t.belongs_to :secret
      t.integer :last_edited_by_id, index: true
    end
  end
end

