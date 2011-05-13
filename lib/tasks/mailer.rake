namespace :mailer do
     desc 'Send massmailer to Subscribed users'

     #Task to be used for sending mailers to sub-scribed users only from the d/b
     task :send => :environment do
           count = 0
            Subscriber.find(:all, :conditions => ["is_subscribed = true"]).each do |subscriber|
             begin
                   Notifier.deliver_massmailer(subscriber)
                   count += 1
             rescue
                   puts "#{subscriber.login} - Error in sending to #{subscriber.email}"
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
                  Notifier.deliver_massmailer_mail(mail,user.unique_identifier)
                  count +=1
          end
          puts "Mail sent to #{count} users"
     end

end
