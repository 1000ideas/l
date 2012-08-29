class CreateNews < ActiveRecord::Migration
  def self.up
    create_table :news do |t|
      t.text :content
      t.string :title
      t.attachment :photo
      t.timestamps
    end
    L::News.create_translation_table! :title => :string, :content => :text
  end

  def self.down
    drop_table :news
    L::News.drop_translation_table!
  end
end
