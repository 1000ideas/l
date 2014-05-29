class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
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
    add_index :pages, :url
    add_index :pages, :deleted_at

    L::Page.create_translation_table!(title: :string, content: :text)
    add_column L::Page.translations_table_name, :deleted_at, :datetime, null: true
  end

  def self.down
    L::Page.drop_translation_table!
    drop_table :pages
  end
end
