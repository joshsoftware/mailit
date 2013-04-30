class Newsletter < ActiveRecord::Base
  validates_presence_of :mailer_subject
  #validates_attachment_presence :template ,:message => "must be uploaded"
  
  # Paperclip
  has_attached_file :template
end
