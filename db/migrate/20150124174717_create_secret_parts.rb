class CreateSecretParts < ActiveRecord::Migration
  def change
    create_table :secret_parts do |t|
      t.integer :index
      t.integer :secret_id
    end
  end
end

