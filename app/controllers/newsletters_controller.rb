require 'csv'

class NewslettersController < ApplicationController

  before_filter :authentication_check, :only => [:manage,:send_newsletters]

  def index
    @news_index_list=Newsletter.where(:type_of_mailer =>"database").paginate(:page => params[ :page ],:per_page => 10).order('created_at DESC')
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
          flash[:notice] = I18n.t('notice.newsletter_sending_started')
          #Mailer to external db 
        elsif params[:send_mail] == "externaldb" and !params[:csv_upload].blank?
          external_database_mailer(news,params[:csv_upload],template_to_render)
        else
          flash[:error] = I18n.t('error.all_mandatory_fields')
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
        #system("rake mailer:verify_mail &")
        flash[:notice] = I18n.t('notice.newsletter_sent_success')
      rescue Exception => e
        puts "Error:=>#{e.message}"
      end
    end
  end

  def external_database_mailer(newsletter,uploaded_csv,template_to_render)
    ext_db_count = 0 
    begin
      external_users=CSV.parse(uploaded_csv.read)
      external_users.each do |row|
        unique_identifier = Digest::MD5.hexdigest(row[0])
        Notifier.massmailer(params[:subject],template_to_render, row[0],unique_identifier).deliver
        flash[:notice] = I18n.t('notice.newsletter_sent_success')
        ext_db_count += 1
      end
    rescue Exception => e
      puts "Error:=>#{e.message}"
      flash[:error] = I18n.t('error.invalid_csv')
    end
    Rails.logger.info "Mail sent to =============>#{ext_db_count} users"
    if !newsletter.notify_email.blank?
      newsletter.notify_email.split(",").each do |email|
        Notifier.massmailer("This is to notify you that below newsletter has been sent to the database",template_to_render,email,"").deliver
      end
    end
  end

end
