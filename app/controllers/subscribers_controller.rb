require 'csv'

class SubscribersController < ApplicationController

  USER, PASSWORD = 'newsletter', 'josh123'
  before_filter :authentication_check, :only => [:newsletters,:import_subscribers,:remove_bounced_subscribers,:send_newsletters]

            
  #Method to unsubscribe the user from newsletter on the basis of incoming uid
  def unsubscribe
    user = Subscriber.find_by_unique_identifier(params[:id])
    user.update_attribute(:is_subscribed, false)
    user.save!
    render
  end

  def import_subscribers
    if request.get?
     render
    else 
      if params[:subscriber_csv] == nil
        flash[:error] = "You must upload CSV file."
      else
        begin
          Subscriber.import(params[:subscriber_csv])
          flash[:notice] = "Import Successful. [#{Subscriber.import_count}] users imported"
        rescue Exception => e
          puts "Error:=>#{e.message}"
          flash[:error] = "Please upload CSV file only =>#{e.message}"
        end
      end
    end  
  end

  def remove_bounced_subscribers
    if request.get?
     render
    else 
      if params[:bounces_csv] == nil
        flash[:error] = "You must upload CSV file."
      else
        begin
          Subscriber.remove_bounced_users(params[:bounces_csv])
          flash[:notice] = "[#{Subscriber.removal_count}] users removed"
        rescue Exception => e
          puts "Error:=>#{e.message}"
          flash[:error] = "Please upload CSV file only =>#{e.message}"
        end
      end
    end  
  end

  def send_newsletters

  if request.get?
    render
  else
    news=Newsletter.new(:mailer_subject => params[:subject],:template => params[:template], :type_of_mailer => params[:send_mail], 
                        :notify_email => params[:notification_email])
      if news.valid?
         news.save
         #get the url of the template to be rendered
         template_to_render=news.template.url
          #Test_mailer
          if params[:send_mail] == "test" and !params[:test_email_address].blank?
             send_testmailers(news,params[:test_email_address],template_to_render)
          #Mailer to subscribed users in the database
          elsif params[:send_mail] == "database"
             system("rake mailer:send_newsletters news_id=#{news.id} template_to_render=#{template_to_render} &")
             flash[:notice] = "Started sending newsletters. You will be notified upon completion."
             #Add Month to index on home page
             index=Homeindex.new(:month => news.created_at.strftime("%B_%G"))
             index.save
          #Mailer to external db 
          elsif params[:send_mail] == "externaldb" and !params[:csv_upload].blank?
            
             begin
               @uploaded_csv=CSV::Reader.parse(params[:csv_upload])
               @uploaded_csv.each do |row|
                  unique_identifier = Digest::MD5.hexdigest(row[0])
                  begin
                    Notifier.massmailer(params[:subject],template_to_render, row[0],unique_identifier).deliver
                    flash[:notice] = "Email sent successfully"
                  rescue Exception => e
                    puts "Error:=>#{e.message}"
                  end  
               end
             rescue Exception => e
                 puts "Error:=>#{e.message}"
                 flash[:error] = "Invalid csv file.Please correct it & try again."
             end  
          else
            flash[:error] = "Please enter all mandatory fields(*)"
          end
      #when newsletter is invalid has some errors in it    
      else
         flash[:error] = news.errors.full_messages.join(', ')
      end
    render :action => :send_newsletters
  end
  end

  def send_testmailers(newsletter,tst_email_address,template_to_render)
    #Separate the comma separated email id's
    tst_email_address.split(",").each do |email|
      unique_identifier = Digest::MD5.hexdigest(email)
      begin
        Notifier.massmailer(newsletter.mailer_subject,template_to_render,email,unique_identifier).deliver
        flash[:notice] = "Email sent successfully"
      rescue Exception => e
        puts "Error:=>#{e.message}"
      end  
    end
  end

  private
  def authentication_check
      authenticate_or_request_with_http_basic do |user, password|
      user == USER && password == PASSWORD
      end
  end

end
