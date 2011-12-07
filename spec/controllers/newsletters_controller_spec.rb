require 'spec_helper'

$email_success_notification = "Newsletter sent successfully"
$db_email_success_notification = "Started sending newsletters. You will be notified upon completion."

describe NewslettersController do
  let(:news) { Factory(:newsletter) }

  before(:each) do
    #This call is necessary to by_pass the basic authentication added while running your specs for send_newsletters action
    by_pass_basic_authentication
    #This is to check delivery of emails where-ever necessary
    ActionMailer::Base.deliveries = []
  end

  context "should validate for" do
    it "subject and template when no values are provided" do
      post :send_newsletters
      flash[:error].should eq("Mailer subject can't be blank, Template file name must be set")
      ActionMailer::Base.deliveries.should be_empty
    end

    it "subject when not provided" do
      post :send_newsletters,:subject =>'',:template =>fixture_file_upload("spec/test.html", mime_type = nil, binary = false),:send_mail =>'test'
      flash[:error].should eq("Mailer subject can't be blank")
      ActionMailer::Base.deliveries.should be_empty
    end

    it "template when not provided" do
      post :send_newsletters,:subject =>'TestSubject123',:template =>'',:send_mail =>'test'
      flash[:error].should eq("Template file name must be set")
      ActionMailer::Base.deliveries.should be_empty
    end 

    it "email adress when not provided" do
      post :send_newsletters,:subject =>'TestSubject123',:template =>fixture_file_upload("spec/test.html", mime_type = nil, binary = false),:send_mail =>'test'
      flash[:error].should eq("Please enter all mandatory fields(*)")
      ActionMailer::Base.deliveries.should be_empty
    end

    it "csv when not provided" do
      post :send_newsletters,:subject =>'TestSubject123',:template =>fixture_file_upload("spec/test.html", mime_type = nil, binary = false),
        :send_mail =>'externaldb'     
      flash[:error].should eq("Please enter all mandatory fields(*)")
      ActionMailer::Base.deliveries.should be_empty
    end 

  end

  context "should send" do
    it "test mail to single user" do
      post :send_newsletters,:subject =>'TestSubject123',:template =>fixture_file_upload("spec/test.html", mime_type = nil, binary = false),
        :send_mail =>'test',:test_email_address=>'joshsoftwaretest1@gmail.com'
      flash[:notice].should eq($email_success_notification)
      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.count.should eq(1)
    end

    it "test mail to multiple users" do
      post :send_newsletters,:subject =>'TestSubject123',:template =>fixture_file_upload("spec/test.html", mime_type = nil, binary = false),
        :send_mail =>'test',:test_email_address=>'joshsoftwaretest1@gmail.com,joshsoftwaretest2@gmail.com'
      flash[:notice].should eq($email_success_notification)
      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.count.should eq(2)
    end    

    it "mail to external database" do
      post :send_newsletters,:subject =>'TestSubject123',:template =>fixture_file_upload("spec/test.html", mime_type = nil, binary = false),
        :send_mail =>'externaldb',:csv_upload =>fixture_file_upload("spec/test.csv", mime_type = nil, binary = false)
      flash[:notice].should eq($email_success_notification)
      #Below the delivery count is checked as 1 because the input file "test.csv" provided above contains only one email
      ActionMailer::Base.deliveries.count.should eq(1)
    end

=begin    
    #We cannot validate this scenario using "ActionMailer::Base.deliveries" as this triggers rake task in the background
    it "mail to database" do
      post :send_newsletters,:subject =>'TestSubject123',:template =>fixture_file_upload("spec/test.html", mime_type = nil, binary = false),:send_mail =>'database'
      flash[:notice].should eq($db_email_success_notification)
    end
=end

  end

end



