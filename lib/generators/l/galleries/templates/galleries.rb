class CreateGalleries < ActiveRecord::Migration
  def self.up
    create_table :galleries do |t|
      t.text :name
      t.text :content

      t.timestamps
    end
    L::Gallery.create_translation_table! :name => :string, :content => :text
  end

  def self.down
    drop_table :galleries
    L::Gallery.drop_translation_table!
  end
end
