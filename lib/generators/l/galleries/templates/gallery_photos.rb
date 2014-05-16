class CreateGalleryPhotos < ActiveRecord::Migration
  def self.up
    create_table :gallery_photos do |t|
      t.integer :gallery_id
      t.attachment :photo

      t.datetime :deleted_at
      t.timestamps
    end

    add_index :gallery_photos, :deleted_at, null: true
  end

  def self.down
    drop_table :gallery_photos
  end
end
