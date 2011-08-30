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


    #Method to import users from csv into db
    def self.import
        import_cnt=0
        #This will be the final csv file including new merged users to be imported into d/b
        #CSV.open("finallist_11thmay.csv", "r").each do |row|
          CSV.open("august_monthlyleads.csv", "r").each do |row|
          begin
             next if row.blank?
             Subscriber.create!(:first_name => row[0],
                                :last_name => row[1],
                                :email => row[2])
             import_cnt+=1
          rescue Exception => e
             puts "Error: #{row[2]}: #{e.message}"
          end
        end
        puts "Total uers imported::#{import_cnt}"  
    end

=begin    
    #Method to import users from uploaded csv into db
    def self.import(subscriber_csv)
          @subscriber_list=CSV::Reader.parse(subscriber_csv)
          @subscriber_list.each do |row|
          begin
             next if row.blank?
             Subscriber.create!(:first_name => row[0],
                                :last_name => row[1],
                                :email => row[2])
          rescue Exception => e
             puts "Error: #{row[2]}: #{e.message}"
          end
        end
    end
=end

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
       puts "Total un-subscribed users:#{un_subscribe_count}"
    end


    #Method to remove bounced email/users from db
    def self.remove_bounced_users
       rem_count=0
        #This will be the i/p csv containing the single column for the email id's of bounced users
        CSV.open("bounces.csv", "r").each do |row|
           
	   user = Subscriber.find_by_email(row[0])
	   if (user!=nil)
              #next if not user
	      user.delete
              rem_count=rem_count+1
           end
	end
       puts "Total removed users:#{rem_count}"
    end

    def unsubscribe!
	update_attribute(:is_subscribed, false)
    end
end
