class DownloadsController < ApplicationController
  
  include DownloadsHelper
  
  layout "downloads"
  
  def index
    @current_site = current_site
    @current_site.name = "Gute Arbeit für Alleinerziehende | Downloads"
  end
  
end