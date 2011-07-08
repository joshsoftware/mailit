class NewsletterTemplate < ActiveRecord::Migration
  def self.up
    add_column :newsletters, :template_file_name, :string
    add_column :newsletters, :template_content_type, :string
    add_column :newsletters, :template_file_size, :integer
  end

  def self.down
   remove_column :newsletters, :template_file_name
   remove_column :newsletters, :template_content_type
   remove_column :newsletters, :template_file_size
  end
end
