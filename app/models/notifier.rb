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


   # Method to be used for Final mailer
   # Here the parameter "receiver" will be subscriber-user object
   def massmailer(receiver)
       setup_email( receiver.email )
       #current date value on which mailer will be sent
       @dt=Date.today.strftime("%B %G")
       @subject = "Josh Software | Newsletter | #{@dt}"
       @code=receiver.unique_identifier
   end


=begin
  def massmailer(subject,mailer_template_to_render,email,uid)
       setup_email(email )
       #current date value on which mailer will be sent
       @dt=Date.today.strftime("%B %G")
       @subject = subject
       @code=uid
       @tmplte=mailer_template_to_render
  end 
=end

  # Same method below can be used for test & final mailers
  protected
  def setup_email(mail)
      @from="Josh Software<marketing@joshsoftware.com>"
      @recipients= mail
      @sent_on = Time.now
      @content_type = "text/html"
  end 

end

