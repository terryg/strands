ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  map.resources :users, :sessions

  #easier routes for restful_authentication
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.activate '/activate', :controller => 'users', :action => 'activate'
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.reset_password '/reset_password', :controller => 'users', :action => 'reset_password'

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "strands"

  # allow neat perma urls
  map.connect 'nodes',
    :controller => 'nodes', :action => 'index'
  map.connect 'nodes/page/:page',
    :controller => 'nodes', :action => 'index',
    :page => /\d+/

  map.connect 'nodes/:year/:month/:day',
    :controller => 'nodes', :action => 'find_by_date',
    :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/
  map.connect 'nodes/:year/:month',
    :controller => 'nodes', :action => 'find_by_date',
    :year => /\d{4}/, :month => /\d{1,2}/
  map.connect 'nodes/:year',
    :controller => 'nodes', :action => 'find_by_date',
    :year => /\d{4}/

  map.connect 'nodes/:year/:month/:day/page/:page',
    :controller => 'nodes', :action => 'find_by_date',
    :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/, :page => /\d+/
  map.connect 'nodes/:year/:month/page/:page',
    :controller => 'nodes', :action => 'find_by_date',
    :year => /\d{4}/, :month => /\d{1,2}/, :page => /\d+/
  map.connect 'nodes/:year/page/:page',
    :controller => 'nodes', :action => 'find_by_date',
    :year => /\d{4}/, :page => /\d+/

  map.connect 'nodes/:year/:month/:day/:title',
    :controller => 'nodes', :action => 'permalink',
    :year => /\d{4}/, :day => /\d{1,2}/, :month => /\d{1,2}/

  map.connect 'nodes/category/:id',
    :controller => 'nodes', :action => 'category'
  map.connect 'nodes/category/:id/page/:page',
    :controller => 'nodes', :action => 'category',
    :page => /\d+/

  map.connect 'nodes/tag/:id',
    :controller => 'nodes', :action => 'tag'
  map.connect 'nodes/tag/:id/page/:page',
    :controller => 'nodes', :action => 'tag',
    :page => /\d+/

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
