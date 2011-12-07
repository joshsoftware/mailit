require 'spec_helper'

describe Subscriber do

  let(:sub_user) { Factory(:subscriber) }

  context "should not be valid" do

    it "without first name" do
      user_wo_fn= Factory.build(:subscriber,:first_name => "")
      user_wo_fn.should_not be_valid
    end

    it "without last name" do
      user_wo_ln= Factory.build(:subscriber,:last_name => "")
      user_wo_ln.should_not be_valid
    end

    it "without email" do      
      user_wo_email= Factory.build(:subscriber,:email => "")
      user_wo_email.should_not be_valid
    end   

    it "with duplicate email" do
      dup_email_user= Factory.build(:subscriber,:email => sub_user.email)
      dup_email_user.should_not be_valid
    end

  end  

  context "should be valid" do

    it "with first name,last name and email" do
      sub_user.should be_valid    
    end

  end 

  it "should default to subscribed user" do
    sub_user.is_subscribed.should eq(true)
  end

end
