require 'spec_helper'

describe Newsletter do

  let(:news) { Factory(:newsletter) }

  context "should not be valid" do
    it "without mailer subject" do
      news_wo_ms= Factory.build(:newsletter,:mailer_subject => "")
      news_wo_ms.should_not be_valid
    end

    it "without template" do
      news_wo_mt= Factory.build(:newsletter,:template => "")
      news_wo_mt.should_not be_valid
    end
  end

  context "should be valid" do
    it "with mailer_subject, template and default type_of_mailer(test) " do
      news.should be_valid
    end

    it "with mailer_subject, template and type_of_mailer as database" do
      news= Factory.build(:newsletter,:type_of_mailer => "db")
      news.should be_valid
    end

    it "with mailer_subject, template and type_of_mailer as external database" do
      news= Factory.build(:newsletter,:type_of_mailer => "externaldb")
      news.should be_valid
    end

    it "with default mailer_status as sending" do
      news.mailer_status.should eq("sending") 
    end
  end

end


