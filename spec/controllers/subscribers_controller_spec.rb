require 'spec_helper'

module SubscriberHelper
  def import_single_subscriber
    post :import_subscribers,:subscriber_csv =>fixture_file_upload("spec/single_subscriber.csv", mime_type = nil, binary = false)
    Subscriber.all.count.should eq(1)
  end

  def import_three_subscribers
    post :import_subscribers,:subscriber_csv =>fixture_file_upload("spec/three_subscribers.csv", mime_type = nil, binary = false)
    Subscriber.all.count.should eq(3)
  end
end

describe SubscribersController do

  include SubscriberHelper

  before(:each) do
    #This call is necessary to by_pass the basic authentication added while running your specs for send_newsletters action
    by_pass_basic_authentication
  end

  context "when unsubscribed" do
    let(:sub_user) { Factory(:subscriber) }

    it "should unsubscribe the user" do
      sub_user.is_subscribed.should == true
      #Started GET "/unsubscribe/01ac5133869dbe739fe5745aacc15900"
      get :unsubscribe, :id => sub_user.unique_identifier
      sub_user.reload.is_subscribed.should == false
    end
  end

  context "should not import subscribers when" do
    it "no file is uploaded" do
      post :import_subscribers
      flash[:error].should eq(I18n.t('error.csv_upload'))
      Subscriber.all.count.should eq(0)
    end

    it "file with invalid extension is uploaded" do
      post :import_subscribers,:subscriber_csv =>fixture_file_upload("spec/test.html", mime_type = nil, binary = false)
      flash[:error].should eq(I18n.t('error.csv_upload_only'))
      Subscriber.all.count.should eq(0)
    end

    it "invalid CSV file is uploaded" do
      post :import_subscribers,:subscriber_csv =>fixture_file_upload("spec/test.csv", mime_type = nil, binary = false)
      Subscriber.all.count.should eq(0)
    end
  end

  context "should import" do
    it "one subscriber when valid CSV file with single record is uploaded" do
      import_single_subscriber
    end

    it "three subscribers when valid CSV file with three records is uploaded" do
      import_three_subscribers
    end
  end

  context "should not import" do
    it "same subscriber again" do
      sub_user = Factory(:subscriber,:email=>"josh1test1@gmail.com")
      post :import_subscribers,:subscriber_csv =>fixture_file_upload("spec/single_subscriber.csv", mime_type = nil, binary = false)
      Subscriber.all.count.should eq(1)
    end
  end

  context "should not remove any subscribers when" do
    it "no file is uploaded" do
      import_single_subscriber
      post :remove_bounced_subscribers 
      flash[:error].should eq(I18n.t('error.csv_upload'))
      Subscriber.all.count.should eq(1)
    end

    it "file with invalid extension is uploaded" do
      import_single_subscriber
      post :remove_bounced_subscribers ,:bounces_csv =>fixture_file_upload("spec/test.html", mime_type = nil, binary = false)
      flash[:error].should eq(I18n.t('error.csv_upload_only'))
      Subscriber.all.count.should eq(1)
    end

    it "invalid CSV file is uploaded" do
      import_single_subscriber
      post :remove_bounced_subscribers ,:bounces_csv =>fixture_file_upload("spec/single_subscriber.csv", mime_type = nil, binary = false)
      Subscriber.all.count.should eq(1)
    end
  end

  context "should remove" do
    it "one subscriber when valid CSV file with single record is uploaded" do 
      import_single_subscriber
      post :remove_bounced_subscribers ,:bounces_csv =>fixture_file_upload("spec/single_bounced_subscriber.csv", mime_type = nil, binary = false)
      Subscriber.all.count.should eq(0)
    end

    it "three subscribers when valid CSV file with three records is uploaded" do 
      import_three_subscribers
      post :remove_bounced_subscribers ,:bounces_csv =>fixture_file_upload("spec/three_bounced_subscribers.csv", mime_type = nil, binary = false)
      Subscriber.all.count.should eq(0)
    end
  end

end

