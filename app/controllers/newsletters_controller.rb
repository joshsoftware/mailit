class NewslettersController < ApplicationController

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
          flash[:notice] = "Started sending newsletters. You will be notified upon completion."
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

end
