class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.string :feedlyID
      t.string :title
      t.string :summaryContent
      t.string :canonicalUrl
      t.string :visualUrl
      t.string :originUrl
      t.string :originTitle
      t.integer :engagement
      t.float :engagementRate
      t.integer :published
    end
  end
end
