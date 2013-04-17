class Notifier < ActionMailer::Base

  # Below method will be used for test mailers only
  # Here the incoming parameter "mail" will be string(email) & corresponding uid for that email
  def test_mail(mail,code_to_unsubscribe)
    setup_email( mail )
    #current date value on which mailer will be sent
    @dt=Date.today.strftime("%B %G")
    @subject = "Josh Software | Newsletter | #{@dt}"
    @code=code_to_unsubscribe
  end

  def massmailer(newsletter,mailer_subject,mailer_template_to_render,email,uid)
    setup_email(email )
    #current date value on which mailer will be sent
    @dt=Date.today.strftime("%B %G")
    @subject = mailer_subject
    @code=uid
    @tmplte=mailer_template_to_render
    @subscriber_first_name = Subscriber.find_by_email(email).try(:first_name)

    #newsletter title and url to be used in the template to be sent for META tags
    @newsletter_title = "#{newsletter.created_at.strftime("%B %G")} Newsletter"
    @current_newsletter_url = "#{DOMAIN_URL}#{newsletter.created_at.strftime("%B_%G").gsub("_","")}_Newsletter"
  end 


  # Same method below can be used for test & final mailers
  protected
  def setup_email(mail)
    @from="Josh Software<marketing@joshsoftware.com>"
    @recipients= mail
    @sent_on = Time.now
    @content_type = "text/html"
  end 

end

