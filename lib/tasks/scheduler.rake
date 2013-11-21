require 'rest_client'
require 'json'

desc "Remove the blocked,bounced,spam & invalid users from sendgrid account using sendgrid API"

task :clean_up_invalid_users_from_sendgrid_account => :environment do

  total_users_to_be_deleted = []

  block_response = RestClient.post('https://sendgrid.com/api/blocks.get.json', :api_user=> ENV['PROD_USERNAME'] , :api_key=> ENV['PROD_PASSWORD'])
  b=JSON.parse(block_response)
  b.collect{|i| total_users_to_be_deleted << i['email']}

  delete_blocks_url = 'https://sendgrid.com/api/blocks.delete.json'
  #delete from sendgrid
  RestClient.post(delete_blocks_url, :api_user=> ENV['PROD_USERNAME'] , :api_key=> ENV['PROD_PASSWORD'])

  bounce_response = RestClient.post('https://sendgrid.com/api/bounces.get.json', :api_user=> ENV['PROD_USERNAME'] , :api_key=> ENV['PROD_PASSWORD'])
  bo=JSON.parse(bounce_response)
  bo.collect{|i| total_users_to_be_deleted << i['email']}

  delete_bounced_url = 'https://sendgrid.com/api/bounces.delete.json'
  #delete from sendgrid
  RestClient.post(delete_bounced_url, :api_user=> ENV['PROD_USERNAME'] , :api_key=> ENV['PROD_PASSWORD'])
  
  spam_response = RestClient.post('https://sendgrid.com/api/spamreports.get.json', :api_user=> ENV['PROD_USERNAME'] , :api_key=> ENV['PROD_PASSWORD'])
  sp=JSON.parse(spam_response)
  sp.collect{|i| total_users_to_be_deleted << i['email']}

  delete_spam_url = 'https://sendgrid.com/api/spamreports.delete.json'
  #delete from sendgrid
  RestClient.post(delete_spam_url, :api_user=> ENV['PROD_USERNAME'] , :api_key=> ENV['PROD_PASSWORD'])
  
  invalid_response = RestClient.post('https://sendgrid.com/api/invalidemails.get.json', :api_user=> ENV['PROD_USERNAME'] , :api_key=> ENV['PROD_PASSWORD'])
  inv=JSON.parse(invalid_response)
  inv.collect{|i| total_users_to_be_deleted << i['email']}

  delete_invalid_url = 'https://sendgrid.com/api/invalidemails.delete.json'
  #delete from sendgrid
  RestClient.post(delete_invalid_url, :api_user=> ENV['PROD_USERNAME'] , :api_key=> ENV['PROD_PASSWORD'])

  #Need to delete the users belonging to all above category from our own database as well collected under the array total_users_to_be_deleted
  if total_users_to_be_deleted.empty?
    total_users_to_be_deleted.each do |user_email|
      s = Subscriber.where(:email=> user_email)
      s.delete if s.blank?
    end
  end
end

#task to take database backup on heroku using 'pgbackup' addon & delete the oldest amongst 7 backups taken
task :take_db_backup_on_heroku => :environment do
   system("heroku pgbackups:capture --expire")
end
