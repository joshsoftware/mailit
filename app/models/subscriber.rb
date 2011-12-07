require 'csv'
require 'digest/md5'

class Subscriber < ActiveRecord::Base
  validates_presence_of :first_name,:last_name,:email
  validates :email, :uniqueness => true

  scope :active, where(:is_subscribed => true)

  before_create :generate_uid

  def generate_uid
    self.unique_identifier = Digest::MD5.hexdigest(self.email)
  end

  #Method to import users from uploaded csv into db
  def self.import(subscriber_csv)
    @@import_cnt=0
    @subscriber_list=CSV::Reader.parse(subscriber_csv)
    @subscriber_list.each do |row|
      begin
        next if row.blank?
        Subscriber.create!(:first_name => row[0],
                           :last_name => row[1],
                           :email => row[2])
        @@import_cnt+=1
      rescue Exception => e
        return "#{e.message}"
      end
    end
  end

  #Method to utilize imported count in controller 
  def self.import_count
    @@import_cnt 
  end

  #This method will not be required in future. It will only be required for first time to update the flag
  #in the database for un-subscribed users
  def self.scrub
    un_subscribe_count=0
    #This will be the i/p csv containing the single column for the email id's of unsubscribed users
    CSV.open("my_unsubscribelist.csv", "r").each do |row|

      user = Subscriber.find_by_email(row[0])
      if (user!=nil)
        #next if not user
        puts user.email
        user.unsubscribe!
        user.save!
        un_subscribe_count=un_subscribe_count+1
      end
    end
    #puts "Total un-subscribed users:#{un_subscribe_count}"
  end


  #Method to remove bounced email/users from db
  def self.remove_bounced_users(bounces_csv)
    @@rem_count=0
    @subscriber_removal_list=CSV::Reader.parse(bounces_csv)
    @subscriber_removal_list.each do |row|
      begin
        user = Subscriber.find_by_email(row[0])
        if (user!=nil)
          user.delete
          @@rem_count+=1
        end
      rescue Exception => e
        return "#{e.message}"
      end
    end
  end

  #Method to utilize removed count in controller 
  def self.removal_count
    @@rem_count 
  end

  def unsubscribe!
    update_attribute(:is_subscribed, false)
  end
end
