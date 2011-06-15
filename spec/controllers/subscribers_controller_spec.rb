require 'spec_helper'

describe SubscribersController do
  let(:sub_user) { Factory(:subscriber) }

  it "should unsubscribe the user" do
    #Started GET "/unsubscribe/01ac5133869dbe739fe5745aacc15900"
    get :unsubscribe, :id => sub_user.unique_identifier
    @unsubscribed_user=Subscriber.last
    @unsubscribed_user.is_subscribed.should ==false
  end

end
