class HomeController < ApplicationController

  def index
    @home_index_list=Homeindex.paginate(:page => params[ :page ],:per_page => 10).order('created_at DESC')
  end

end
