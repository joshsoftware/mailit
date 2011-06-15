class Newsletter < ActiveRecord::Base
  validates_presence_of :mailer_subject,:mailer_template
end
