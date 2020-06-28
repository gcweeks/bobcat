class CreateFeeds < ActiveRecord::Migration[6.0]
  def change
    create_table :feeds do |t|
      t.references :user, null: false, foreign_key: true

      t.string :name
      t.string :query
    end
  end
end
