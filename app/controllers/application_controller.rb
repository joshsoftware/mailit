class ApplicationController < ActionController::Base
  protect_from_forgery
  USER, PASSWORD = 'newsletter', 'josh123'

  private
  def authentication_check
    authenticate_or_request_with_http_basic do |user, password|
      user == USER && password == PASSWORD
    end
  end

end
