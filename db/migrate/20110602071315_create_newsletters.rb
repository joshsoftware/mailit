class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters do |t|
      t.string :mailer_subject
      t.string :type_of_mailer
      t.datetime :sent_at
    
      t.timestamps
    end
  end

  def self.down
    drop_table :newsletters
  end
end
