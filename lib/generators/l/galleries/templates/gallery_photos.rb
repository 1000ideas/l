class CreateGalleryPhotos < ActiveRecord::Migration
  def self.up
    create_table :gallery_photos do |t|
      t.integer :gallery_id
      t.attachment :photo

      t.timestamps
    end
  end

  def self.down
    drop_table :gallery_photos
  end
end
