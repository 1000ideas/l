class CreateGalleries < ActiveRecord::Migration
  def self.up
    create_table :galleries do |t|
      t.text :name
      t.text :content

      t.datetime :deleted_at
      t.timestamps
    end
    add_index :galleries, :deleted_at, null: true

    L::Gallery.create_translation_table!(name: :string, content: :text)
    add_column L::Gallery.translations_table_name, :deleted_at, :datetime, null: true
  end

  def self.down
    L::Gallery.drop_translation_table!
    drop_table :galleries
  end
end
