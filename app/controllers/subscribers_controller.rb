require 'csv'

class SubscribersController < ApplicationController

  USER, PASSWORD = 'newsletter', 'josh123'
  before_filter :authentication_check, :only => [:import_subscribers,:remove_bounced_subscribers]

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

  private
  def authentication_check
    authenticate_or_request_with_http_basic do |user, password|
      user == USER && password == PASSWORD
    end
  end

end
