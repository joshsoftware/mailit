class CreateHomeindices < ActiveRecord::Migration
  def self.up
    create_table :homeindices do |t|
      t.string :month
      t.string :newsletter_link

      t.timestamps
    end
  end

  def self.down
    drop_table :homeindices
  end
end
