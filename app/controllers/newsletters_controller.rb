require 'csv'

class NewslettersController < ApplicationController

  before_filter :authentication_check, :only => [:manage,:send_newsletters]

  def index
    @news_index_list=Newsletter.where(:type_of_mailer =>"database").paginate(:page => params[ :page ],:per_page => 10).order('created_at DESC')
  end

  def send_newsletters
    render and return if request.get?
   
    parameter  = params
    news=Newsletter.new(:mailer_subject => parameter[:subject],:template => parameter[:template], :type_of_mailer => parameter[:send_mail], 
                        :notify_email => parameter[:notification_email])
    
    flash[:error] = news.errors.full_messages.join(', ') and return unless news.valid?
    
    news.save
    #get the url of the template to be rendered
    template_to_render=news.template.url 
    #Test_mailer
    send_testmailers(news,parameter[:test_email_address],template_to_render) and return if parameter[:send_mail] == "test" and !parameter[:test_email_address].blank?     
    #Mailer to external db 
    external_database_mailer(news,parameter[:csv_upload],template_to_render) and return if parameter[:send_mail] == "externaldb" and !parameter[:csv_upload].blank?
    #when newsletter is invalid has some errors in it    
    flash[:error] = I18n.t('error.all_mandatory_fields') and return if parameter[:send_mail] != "database"
    #Mailer to subscribed users in the database
    system("rake mailer:send_newsletters news_id=#{news.id} template_to_render=#{template_to_render} &")
    flash[:notice] = I18n.t('notice.newsletter_sending_started')
  end

  def send_testmailers(newsletter,tst_email_address,template_to_render)
    #Separate the comma separated email id's
    tst_email_address.split(",").each do |email|
      unique_identifier = Digest::MD5.hexdigest(email)
      begin
        Notifier.massmailer(newsletter,newsletter.mailer_subject,template_to_render,email,unique_identifier).deliver
        #system("rake mailer:verify_mail &")
        flash[:notice] = I18n.t('notice.newsletter_sent_success')
      rescue Exception => e
        puts "Error:=>#{e.message}"
      end
    end
  end

  def external_database_mailer(newsletter,uploaded_csv,template_to_render)
    begin
      CSV.parse(uploaded_csv.read).each do |row|
        Notifier.massmailer(newsletter,params[:subject],template_to_render, row[0],  Digest::MD5.hexdigest(row[0])).deliver
      end
      flash[:notice] = I18n.t('notice.newsletter_sent_success')
    rescue Exception => e
      flash[:error] = I18n.t('error.invalid_csv')
    end
    if !newsletter.notify_email.blank?
      newsletter.notify_email.split(",").each do |email|
        Notifier.massmailer(newsletter,"This is to notify you that below newsletter has been sent to the database",template_to_render,email,"").deliver
      end
    end
  end

end
