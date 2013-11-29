class Newsletter < ActiveRecord::Base
  validates_presence_of :mailer_subject
  validates_attachment_presence :template ,:message => "must be uploaded"
  
  # Paperclip
  has_attached_file :template

  # Move the uploaded template to /public directory
  after_save(:on => :create) do
    system "cp", self.template.path.to_s, "#{Rails.root.join('public').to_s}" if self.type_of_mailer == "database"
  end
end
