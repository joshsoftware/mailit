require 'csv'
require 'digest/md5'

class Subscriber < ActiveRecord::Base
    validates :email, :uniqueness => true
	
    scope :active, where(:is_subscribed => true)

    before_create :generate_uid

    def generate_uid
        self.unique_identifier = Digest::MD5.hexdigest(self.email)
    end

    def self.import
        #This will be the final csv file including new merged users to be imported into d/b
         CSV.open("finallist_11thmay.csv", "r").each do |row|
         #CSV.open("local_emails.csv", "r").each do |row|
          begin
           if (row!=nil or row!="")
           
            Subscriber.create!(:first_name => row[0],
                               :last_name => row[1],
                               :email => row[2])
           end
          rescue Exception => e
            puts "Error: #{row[2]}: #{e.message}"
          end
        end
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
       puts "Total un-subscribed users:#{un_subscribe_count}"
    end


    def unsubscribe!
	update_attribute(:is_subscribed, false)
    end
end
