class Newsletter < ActiveRecord::Base
  validates_presence_of :mailer_subject
  validates_attachment_presence :template
  
  # Paperclip
  has_attached_file :template
end
