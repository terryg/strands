# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'authenticated_system'

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_strands_session_id'

  before_filter :login_from_cookie
  
  prepend_before_filter :localize

  def localize
    # determine locale and set other relevant stuff
    ActiveRecord::Base.date_format = '%Y-%m-%d'
  end
  
end
