class CreateGalleries < ActiveRecord::Migration
  def self.up
    [:galleries, :gallery_drafts].each do |table_name|
    create_table table_name do |t|
      t.references :gallery if table_name == :gallery_drafts
      t.integer :draft_id if table_name == :galleries
      t.text :name
      t.text :content

      t.datetime :deleted_at
      t.timestamps
    end
    end
    add_index :galleries, :deleted_at, null: true

    L::Gallery.create_translation_table!(name: :string, content: :text)
    add_column L::Gallery.translations_table_name, :deleted_at, :datetime, null: true
    
    create_table :gallery_draft_translations do |t|
      t.references :gallery_draft
      t.string :name
      t.string :locale
      t.text :content      
      t.timestamps
    end

  end

  def self.down
    L::Gallery.drop_translation_table!
    drop_table :gallery_draft_translations
    drop_table :galleries
    drop_table :gallery_drafts
  end
end
