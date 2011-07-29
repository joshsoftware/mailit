namespace :mailer do
     desc 'Send massmailer to Subscribed users'

     #Task to be used for sending mailers to sub-scribed users only
     task :send => :environment do
           count = 0
            #Subscriber.find(:all, :conditions => ["is_subscribed = true"]).each do |subscriber|
            Subscriber.limit(1000).where(["is_subscribed = ?", true]).where(['id > ?', ENV['last_sent'] ]).each do |subscriber|
             begin
                   Notifier.deliver_massmailer(subscriber)
                   puts "Sending mail to #{subscriber.email} completed"
                   Rails.logger.info "Sending mail to #{subscriber.email} completed"
                   count += 1
             rescue
                   puts "#{subscriber.login} - Error in sending to #{subscriber.email}"
                   Rails.logger.info "#{subscriber.login} - Error in sending to #{subscriber.email}"
             end
           end
           puts "Count of subscribed users:#{Subscriber.find(:all, :conditions => ["is_subscribed = true"]).size}"
           puts "Mail sent to #{count} users"
      end

     #Task to be used for sending test mailers
     task :verify_mail => :environment do
           count = 0
           #["ninad@joshsoftware.com","gautam@joshsoftware.com","sethu@joshsoftware.com","vishwadeep@joshsoftware.com"].each do |mail|
           ["ninad@joshsoftware.com"].each do |mail|
                  user=Subscriber.find_by_email(mail)
                  #Notifier.deliver_test_mail(mail,user.unique_identifier)
                  #Below method will avoid the creation of template test_mail.html.erb under /app/views/notifier   
                  Notifier.deliver_massmailer(user)
                  count +=1
          end
          puts "Mail sent to #{count} users"
          Rails.logger.info "Mail sent to #{count} users"
     end

end
