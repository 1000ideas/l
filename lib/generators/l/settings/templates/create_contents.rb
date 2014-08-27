class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents, id: false do |t|
      t.string :id
      t.text :value

      t.timestamps
    end

    add_index :contents, :id, unique: true
  end
end
