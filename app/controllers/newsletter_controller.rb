class NewsletterController < ApplicationController

  def index
    @news_index_list=Newsletter.where(:type_of_mailer =>"database").paginate(:page => params[ :page ],:per_page => 10).order('created_at DESC')
  end

end
