require 'spec_helper'

describe SubscribersController do
  let(:sub_user) { Factory(:subscriber) }

  before(:each) do
    #This call is necessary to by_pass the basic authentication added while running your specs for send_newsletters action
    by_pass_basic_authentication
  end

  it "should unsubscribe the user" do
    sub_user.is_subscribed.should == true
    #Started GET "/unsubscribe/01ac5133869dbe739fe5745aacc15900"
    get :unsubscribe, :id => sub_user.unique_identifier
    sub_user.reload.is_subscribed.should == false
  end

  context "should not import subscribers when" do
    it "no file is uploaded" do
      post :import_subscribers
      flash[:error].should eq(I18n.t('error.csv_upload'))
      Subscriber.all.count.should eq(1)
    end

    it "file with invalid extension is uploaded" do
      post :import_subscribers,:subscriber_csv =>fixture_file_upload("spec/test.html", mime_type = nil, binary = false)
      flash[:error].should eq(I18n.t('error.csv_upload_only'))
      Subscriber.all.count.should eq(1)
    end

    it "invalid CSV file is uploaded" do
      post :import_subscribers,:subscriber_csv =>fixture_file_upload("spec/test.csv", mime_type = nil, binary = false)
      flash[:error].should eq(I18n.t('error.invalid_csv_upload'))
      Subscriber.all.count.should eq(1)
    end
  end

  context "should import" do
    it "one subscriber when valid CSV file with single record is uploaded" do
    end

    it "three subscribers when valid CSV file with three records is uploaded" do
    end
  end
end

