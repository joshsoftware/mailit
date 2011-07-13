class Newsletter < ActiveRecord::Base
  validates_presence_of :mailer_subject
  validates_attachment_presence :template
  
  # Paperclip
  attr_accessor :template_file_name 
  has_attached_file :template
end
