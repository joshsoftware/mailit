class ApplicationController < ActionController::Base
  protect_from_forgery
  USER, PASSWORD = ENV['BASIC_AUTH_USERNAME'], ENV['BASIC_AUTH_PASSWORD']

  private
  def authentication_check
    authenticate_or_request_with_http_basic do |user, password|
      user == USER && password == PASSWORD
    end
  end

end
