#SendGrid configuration
ActionMailer::Base.smtp_settings = {
  :user_name => <%= ENV['PROD_USERNAME'] %>,
  :password => <%= ENV['PROD_PASSWORD'] %>,
  :domain => <%= ENV['DOMAIN'] %>,
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

