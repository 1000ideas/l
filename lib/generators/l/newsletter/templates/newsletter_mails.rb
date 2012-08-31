class CreateNewsletterMails < ActiveRecord::Migration
  def self.up
    create_table :newsletter_mails do |t|
      t.text :mail
      t.string :confirm_token
      t.timestamps
    end
  end

  def self.down
    drop_table :newsletter_mails
  end
end
