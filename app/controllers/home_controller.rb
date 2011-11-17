class HomeController < ApplicationController

  def index
    @home_index_list=Homeindex.find(:all)
  end

end
