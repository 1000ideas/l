class CreateNews < ActiveRecord::Migration
  def self.up
    create_table :news do |t|
      t.text :content
      t.string :title
      t.attachment :photo

      t.datetime :published_at, null: true
      t.datetime :deleted_at, null: true
      t.timestamps
    end
    add_index :news, :deleted_at

    L::News.create_translation_table!(title: :string, content: :text)
    add_column L::News.translations_table_name, :deleted_at, :datetime, null: true
  end

  def self.down
    L::News.drop_translation_table!
    drop_table :news
  end
end
