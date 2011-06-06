class SubscribersController < ApplicationController

  #Method to unsubscribe the user from newsletter on the basis of incoming uid
  def unsubscribe
    user = Subscriber.find_by_unique_identifier(params[:id])
    user.update_attribute(:is_subscribed, false)
    user.save!

    render
  end

  def newsletters
      render
  end


  def send_mailers
    #check if the fields "subject" & "upload_template" are not blank
    if !params[:subject].blank? and !params[:upload_template].blank?
      #Test_mailer
      if params[:send_mail] == "test" and !params[:test_address].blank?
         #Separate the comma separated email id's
         params[:test_email_address].split(",").each do |email|
           unique_identifier = Digest::MD5.hexdigest(email)
           Notifier.deliver_massmailer(params[:subject], params[:upload_template], email,unique_identifier)
         end
      #Mailer to subscribed users in the database
      elsif params[:send_mail] == "database"
        count = 0
        Subscriber.find(:all, :conditions => ["is_subscribed = true"]).each do |subscriber|
          begin
             Notifier.deliver_massmailer(params[:subject], params[:upload_template], subscriber.email,subscriber.unique_identifier)
             count += 1
          rescue
             puts "#{subscriber.login} - Error in sending to #{subscriber.email}"
          end
        end
        puts "Count of subscribed users:#{Subscriber.find(:all, :conditions => ["is_subscribed = true"]).size}"
        puts "Mail sent to #{count} users"
      #Mailer to external db 
      elsif params[:send_mail] == "csv" and !params[:csv_upload].blank?

      
      else
          flash[:notice] = "Please enter all mandatory fields(*)"
          redirect_to :controller => 'subscribers', :action => 'send_mailers'
      end
      flash[:notice] = "Mailer sent sucessfully."
      redirect_to :controller => 'subscribers', :action => 'send_mailers'
    else
      flash[:notice] = "Please enter all mandatory fields(*)"
      render :action => :newsletters
    end 
  end

end
