require 'csv'

class SubscribersController < ApplicationController

  USER, PASSWORD = 'newsletter', 'josh123'
  before_filter :authentication_check, :only => [:newsletters]

            
  #Method to unsubscribe the user from newsletter on the basis of incoming uid
  def unsubscribe
    user = Subscriber.find_by_unique_identifier(params[:id])
    user.update_attribute(:is_subscribed, false)
    user.save!
    render
  end

=begin  
  def newsletters
      render
  end


  def send_mailers
    @news=Newsletter.new(:mailer_subject => params[:subject],:mailer_template => params[:upload_template], :type_of_mailer => params[:send_mail])
      if @news.valid?
          #Test_mailer
          if params[:send_mail] == "test" and !params[:test_email_address].blank?
             #Separate the comma separated email id's
             params[:test_email_address].split(",").each do |email|
             unique_identifier = Digest::MD5.hexdigest(email)
               begin
                 Notifier.deliver_massmailer(params[:subject], params[:upload_template], email,unique_identifier)
                 flash[:notice] = "Email sent successfully"
               rescue Exception => e
                 puts "Error:=>#{e.message}"
               end  
             end
          #Mailer to subscribed users in the database
          elsif params[:send_mail] == "database"
             count = 0
             Subscriber.find(:all, :conditions => ["is_subscribed = true"]).each do |subscriber|
               begin
               Notifier.deliver_massmailer(params[:subject], params[:upload_template], subscriber.email,subscriber.unique_identifier)
               flash[:notice] = "Email sent successfully"
               count += 1
               rescue
                puts "#{subscriber.login} - Error in sending to #{subscriber.email}"
               end
             end
             #puts "Count of subscribed users:#{Subscriber.find(:all, :conditions => ["is_subscribed = true"]).size}"
             #puts "Mail sent to #{count} users"
          #Mailer to external db 
          elsif params[:send_mail] == "externaldb" and !params[:csv_upload].blank?
             begin
               @uploaded_csv=CSV::Reader.parse(params[:csv_upload])
               @uploaded_csv.each do |row|
                  unique_identifier = Digest::MD5.hexdigest(row[2])
                  begin
                    Notifier.deliver_massmailer(params[:subject], params[:upload_template], row[2],unique_identifier)
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
      else
         flash[:error] = @news.errors.full_messages.join(', ')
      end

    render :action => :newsletters
  end
=end
 

  def newsletters

  if request.get?
    render
  else
    @news=Newsletter.new(:mailer_subject => params[:subject],:mailer_template => params[:upload_template], :type_of_mailer => params[:send_mail])
      if @news.valid?
          #Test_mailer
          if params[:send_mail] == "test" and !params[:test_email_address].blank?
             #Separate the comma separated email id's
             params[:test_email_address].split(",").each do |email|
             unique_identifier = Digest::MD5.hexdigest(email)
               begin
                 Notifier.deliver_massmailer(params[:subject], params[:upload_template], email,unique_identifier)
                 flash[:notice] = "Email sent successfully"
               rescue Exception => e
                 puts "Error:=>#{e.message}"
               end  
             end
          #Mailer to subscribed users in the database
          elsif params[:send_mail] == "database"
             count = 0
             Subscriber.find(:all, :conditions => ["is_subscribed = true"]).each do |subscriber|
               begin
               Notifier.deliver_massmailer(params[:subject], params[:upload_template], subscriber.email,subscriber.unique_identifier)
               flash[:notice] = "Email sent successfully"
               count += 1
               rescue
                puts "#{subscriber.login} - Error in sending to #{subscriber.email}"
               end
             end
             #puts "Count of subscribed users:#{Subscriber.find(:all, :conditions => ["is_subscribed = true"]).size}"
             #puts "Mail sent to #{count} users"
          #Mailer to external db 
          elsif params[:send_mail] == "externaldb" and !params[:csv_upload].blank?
             begin
               @uploaded_csv=CSV::Reader.parse(params[:csv_upload])
               @uploaded_csv.each do |row|
                  unique_identifier = Digest::MD5.hexdigest(row[2])
                  begin
                    Notifier.deliver_massmailer(params[:subject], params[:upload_template], row[2],unique_identifier)
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
      else
         flash[:error] = @news.errors.full_messages.join(', ')
      end

    render :action => :newsletters
  end
  end

  private
  def authentication_check
      authenticate_or_request_with_http_basic do |user, password|
      user == USER && password == PASSWORD
      end
  end

end
