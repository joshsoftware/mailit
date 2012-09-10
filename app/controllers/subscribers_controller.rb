class SubscribersController < ApplicationController

  before_filter :authentication_check, :only => [:import_subscribers,:remove_bounced_subscribers,:add_subscriber]

  #Method to unsubscribe the user from newsletter on the basis of incoming uid
  def unsubscribe
    user = Subscriber.find_by_unique_identifier(params[:id])
    user.update_attribute(:is_subscribed, false)
    user.save!
    render
  end

  def add_subscriber
    if request.get?
      render
    else
      subscriber = Subscriber.new(:first_name => params[:first_name],:last_name => params[:last_name],:email => params[:email])
      if subscriber.valid?
        subscriber.save
        flash[:notice] = I18n.t('notice.subscriber_added_success')
      else
        flash[:error] = subscriber.errors.full_messages.join(' , ')
      end
      render
    end   
  end

  def import_subscribers
    if request.get?
      render
    else 
      if params[:subscriber_csv].blank?
        flash[:error] = I18n.t('error.csv_upload')
      else
        begin
          Subscriber.import(params[:subscriber_csv])
          flash[:notice] = "Import Successful. [#{Subscriber.import_count}] users imported"
        rescue Exception => e
          flash[:error] = I18n.t('error.csv_upload_only')
        end
      end
    end  
  end

  def remove_bounced_subscribers
    if request.get?
      render
    else 
      if params[:bounces_csv].blank?
        flash[:error] = I18n.t('error.csv_upload')
      else
        begin
          Subscriber.remove_bounced_users(params[:bounces_csv])
          flash[:notice] = "[#{Subscriber.removal_count}] users removed"
        rescue Exception => e
          flash[:error] = I18n.t('error.csv_upload_only')
        end
      end
    end  
  end

end
