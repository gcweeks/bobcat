class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.string :feedlyID
      t.string :title
      t.string :summary
      t.string :origin
      t.integer :engagement
      t.float :rate
      t.integer :published
    end
  end
end
