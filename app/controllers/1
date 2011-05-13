class SubscribersController < ApplicationController

  #Method to unsubscribe the user from newsletter
  def unsubscribe
    #FasterCSV.open("#{Rails.root}/unsub_ids.csv","a") do |ui|
    #  ui << params[:id]
    #end
    user = Subscriber.find_by_unique_identifier(params[:id])
    user.update_attribute(:is_subscribed, false)
    user.save!

    render
  end

end
