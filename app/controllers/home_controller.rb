class HomeController < ApplicationController
  def index
    @signed_in = logged_in?
  end
end
