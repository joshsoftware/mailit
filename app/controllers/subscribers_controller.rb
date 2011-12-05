require 'csv'

class SubscribersController < ApplicationController

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
        flash[:error] = I18n.t('error.csv_upload')
      else
        begin
          Subscriber.import(params[:subscriber_csv])
          flash[:notice] = "Import Successful. [#{Subscriber.import_count}] users imported"
        rescue Exception => e
          puts "Error:=>#{e.message}"
          flash[:error] = I18n.t('error.csv_upload_only')
        end
      end
    end  
  end

  def remove_bounced_subscribers
    if request.get?
      render
    else 
      if params[:bounces_csv] == nil
        flash[:error] = I18n.t('error.csv_upload')
      else
        begin
          Subscriber.remove_bounced_users(params[:bounces_csv])
          flash[:notice] = "[#{Subscriber.removal_count}] users removed"
        rescue Exception => e
          puts "Error:=>#{e.message}"
          flash[:error] = I18n.t('error.csv_upload_only')
        end
      end
    end  
  end

end
