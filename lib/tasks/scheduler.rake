require 'rest_client'
require 'json'

desc "Remove the blocked,bounced,spam & invalid users from sendgrid account using sendgrid API"

task :clean_up_invalid_users_from_sendgrid_account => :environment do
  delete_blocks_url = 'https://sendgrid.com/api/blocks.delete.json'
  RestClient.post(delete_blocks_url, :api_user=> ENV['PROD_USERNAME'] , :api_key=> ENV['PROD_PASSWORD'])

  delete_bounced_url = 'https://sendgrid.com/api/bounces.delete.json'
  RestClient.post(delete_bounced_url, :api_user=> ENV['PROD_USERNAME'] , :api_key=> ENV['PROD_PASSWORD'])
  
  delete_spam_url = 'https://sendgrid.com/api/spamreports.delete.json'
  RestClient.post(delete_spam_url, :api_user=> ENV['PROD_USERNAME'] , :api_key=> ENV['PROD_PASSWORD'])
  
  delete_invalid_url = 'https://sendgrid.com/api/invalidemails.delete.json'
  RestClient.post(delete_invalid_url, :api_user=> ENV['PROD_USERNAME'] , :api_key=> ENV['PROD_PASSWORD'])
end
