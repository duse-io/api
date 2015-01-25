class CreateShares < ActiveRecord::Migration
  def change
    create_table :shares do |t|
      t.text :content
      t.text :signature
      t.integer :user_id
      t.integer :secret_part_id
    end
  end
end

