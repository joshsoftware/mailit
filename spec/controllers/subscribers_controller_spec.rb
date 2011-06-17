require 'spec_helper'

describe SubscribersController do
  let(:sub_user) { Factory(:subscriber) }

  it "should unsubscribe the user" do
    #Started GET "/unsubscribe/01ac5133869dbe739fe5745aacc15900"
    get :unsubscribe, :id => sub_user.unique_identifier
    @unsubscribed_user=Subscriber.last
    @unsubscribed_user.is_subscribed.should ==false 
  end

 context "should validate for" do

   it "subject and template when no values are provided" do
       post :send_mailers
       flash[:error].should =="Mailer subject can't be blank, Mailer template can't be blank"
    end

   it "subject when not provided" do
       post :send_mailers,:subject =>'',:upload_template =>fixture_file_upload("test.html", mime_type = nil, binary = false),:send_mail =>'test'
       flash[:error].should =="Mailer subject can't be blank"
    end


   it "template when not provided" do
       post :send_mailers,:subject =>'TestSubject123',:upload_template =>'',:send_mail =>'test'
       flash[:error].should =="Mailer template can't be blank"
   end

   it "email adress when not provided" do
       post :send_mailers,:subject =>'TestSubject123',:upload_template =>fixture_file_upload("test.html", mime_type = nil, binary = false),:send_mail =>'test'
       flash[:error].should =="Please enter all mandatory fields(*)"
   end

   it "csv when not provided" do
       post :send_mailers,:subject =>'TestSubject123',:upload_template =>fixture_file_upload("test.html", mime_type = nil, binary = false),:send_mail =>'externaldb'
       flash[:error].should =="Please enter all mandatory fields(*)"
   end

 end

 context "should send" do
  
   it "test mail to single user" do
       post :send_mailers,:subject =>'TestSubject123',:upload_template =>fixture_file_upload("test.html", mime_type = nil, binary = false),:send_mail =>'externaldb',:email_address=>'joshsoftwaretest1@gmail.com'
       flash[:notice].should=="Email sent successfully"
   end

   it "test mail to mulitple users" do
       post :send_mailers,:subject =>'TestSubject123',:upload_template =>fixture_file_upload("test.html", mime_type = nil, binary = false),:send_mail =>'externaldb',:email_address=>'joshsoftwaretest1@gmail.com,joshsoftwaretest2@gmail.com'
      flash[:notice].should=="Email sent successfully"
   end    

 end

end
