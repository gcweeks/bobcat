class CreateTagsItemsJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_join_table :tags, :items do |t|
      t.index :tag_id
      t.index :item_id
    end
  end
end
