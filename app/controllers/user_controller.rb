class UserController < SessionsController
  before_filter :login_required, :only => [ :edit ]

  layout 'default'

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update, :comment ],
         :redirect_to => { :action => :list }
         
  def show
    @user = User.find_by_id(params[:id])  
  end
  
  def edit
    @user = User.find_by_id(session[:user])  
  end
  
end