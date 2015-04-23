class CreatePages < ActiveRecord::Migration
  def self.up
    [:pages, :page_drafts].each do |table_name|
    create_table table_name do |t|
      t.references :page if table_name == :page_drafts
      t.integer :draft_id if table_name == :pages
      t.string :url
      t.string :title
      t.text :meta_description
      t.text :meta_keywords
      t.text :content
      t.integer :position
      t.integer :parent_id, default: nil
      t.integer :hidden_flag, default: 0

      t.datetime :deleted_at, null: true
      t.timestamps
    end
    end
    add_index :pages, :url
    add_index :pages, :deleted_at

    L::Page.create_translation_table!(title: :string, meta_description: :text, meta_keywords: :text, content: :text)
    add_column L::Page.translations_table_name, :deleted_at, :datetime, null: true
  end

  def self.down
    L::Page.drop_translation_table!
    drop_table :pages
    drop_table :page_drafts
  end
end
