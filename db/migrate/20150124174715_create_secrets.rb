class CreateSecrets < ActiveRecord::Migration
  def change
    create_table :secrets do |t|
      t.string :title
    end
  end
end
