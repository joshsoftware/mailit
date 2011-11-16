class HomeController < ApplicationController

  def index
    @home_index_list=Homeindex.find(:all)
  end

  def add_to_index
    if request.get?
      render
    else  
      index=Homeindex.new(:month => params[:month])
      if index.valid?
         index.save
         flash[:notice] = "Home Index updated successfully"
      else
         flash[:error] = index.errors.full_messages.join(', ')
      end
    end    
  end

end
