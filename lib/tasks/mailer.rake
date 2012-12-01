namespace :mailer do
  desc 'Send massmailer to Subscribed users'

  #Task to be used for sending mailers to sub-scribed users only
  task :send => :environment do
    count = 0
    Subscriber.find(:all, :conditions => ["is_subscribed = true"]).each do |subscriber|
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

  #Task to be used for sending mailers to sub-scribed users only
  task :send_newsletters => :environment do
    newsletter_id = ENV['news_id']
    newsletter_template = ENV['template_to_render']
    @newsletter=Newsletter.find(newsletter_id)
    count = 0

    Subscriber.find(:all, :conditions => ["is_subscribed = true"]).each do |subscriber|
      begin
        Notifier.massmailer(@newsletter.mailer_subject,newsletter_template,subscriber.email,subscriber.unique_identifier).deliver
        puts "Sending mail to #{subscriber.email} completed"
        Rails.logger.info "Sending mail to #{subscriber.email} completed"
        count += 1
      rescue
        puts "#{subscriber.login} - Error in sending to #{subscriber.email}"
        Rails.logger.info "#{subscriber.login} - Error in sending to #{subscriber.email}"
      end
    end
    Rails.logger.info "Count of subscribed users:#{Subscriber.find(:all, :conditions => ["is_subscribed = true"]).size}"
    Rails.logger.info "Mail sent to #{count} users"
    #send completion notification email to specified email id's
    if !@newsletter.notify_email.blank?
      @newsletter.notify_email.split(",").each do |email|
        puts "Notification Email ==>#{email}"
        Rails.logger.info "Notification Email ==>#{email}"
        Notifier.massmailer("This is to notify you that below newsletter has been sent to the database",newsletter_template,email,"").deliver
      end  
    end
  end

  #Task to be used for sending test mailers
  task :verify_mail => :environment do
    count = 0
    ["ninad@joshsoftware.com"].each do |mail|
      user=Subscriber.find_by_email(mail)
      Notifier.test_mail(mail,"uid12345").deliver
      #Below method will avoid the creation of template test_mail.html.erb under /app/views/notifier   
      #Notifier.deliver_massmailer(user)
      count +=1
    end
    puts "Mail sent to #{count} users"
    Rails.logger.info "Mail sent to #{count} users"
  end

end
