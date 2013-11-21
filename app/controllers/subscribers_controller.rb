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
    parameter = params

    render and return if request.get?

    @subscriber = Subscriber.new(:first_name => parameter[:first_name],:last_name => parameter[:last_name],:email => parameter[:email])
    flash[:error] = @subscriber.errors.full_messages.join(' , ') and return unless @subscriber.valid?

    @subscriber.save
    flash[:notice] = I18n.t('notice.subscriber_added_success')
    @subscriber = Subscriber.new
    render
  end

  def import_subscribers
    parameter = params

    render and return if request.get?
    flash[:error] = I18n.t('error.csv_upload') and return if parameter[:subscriber_csv].blank?

    begin
      Subscriber.import(parameter[:subscriber_csv])
      flash[:notice] = "Import Successful. [#{Subscriber.import_count}] users imported"
    rescue Exception => e
      flash[:error] = I18n.t('error.csv_upload_only')
    end
  end

  def remove_bounced_subscribers
    parameter = params

    render and return if request.get?
    flash[:error] = I18n.t('error.csv_upload') and return if parameter[:bounces_csv].blank?
    begin
      Subscriber.remove_bounced_users(parameter[:bounces_csv])
      flash[:notice] = "[#{Subscriber.removal_count}] users removed"
    rescue Exception => e
      flash[:error] = I18n.t('error.csv_upload_only')
    end
  end

  #below method is use to take backup of current database on heroku
  def back_up_current_db
    system("rake take_db_backup_on_heroku &")
    flash[:notice] = I18n.t('notice.database_backup_taken')
    redirect_to request.referrer and return
  end

  #below method would remove blocke,bounced,spam & invalid users from sendgrid account as well as from database 
  def clean_up_invalid_users

  end

end
