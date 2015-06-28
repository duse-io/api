class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.string :name
      t.belongs_to :parent
      t.belongs_to :user
    end
  end
end
