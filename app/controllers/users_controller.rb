class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  layout 'default'
  
  # render new.rhtml
  def new
  end

  def edit
    @user = session[:user]
  end
    
  def show
    @user = User.find(params[:id])
  end
  
  def create
    @user = User.new(params[:user])
    @user.save!
    self.current_user = @user
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up! Check your email for an activation code."
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end

  def activate
    self.current_user = User.find_by_activation_code(params[:id])
    if logged_in? && !current_user.activated?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end

  def forgot_password
    if request.post?
      user = User.find_by_email(params[:user][:email])
      if user
        user.create_reset_code
      end
      redirect_back_or_default('/')
    end
  end

  def reset_password
    @user = User.find_by_reset_code(params[:reset_code]) unless params[:reset_code].nil?
    if request.post?
      if @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        self.current_user = @user
        @user.delete_reset_code
        redirect_back_or_default('/')
      else
        render :action => :reset_password
      end
    end
  end
end
