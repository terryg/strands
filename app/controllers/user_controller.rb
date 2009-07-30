class UserController < SessionsController
  before_filter :login_required, :only => [ :edit ]

  layout 'user', :except => 'nodes'

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :update, :add_feed, :destroy_feed ],
         :redirect_to => { :action => :list }
         
  def add_feed
    feed = Feed.create(:url => params[:newfeed], :user_id => session[:user])
    render_text "<li>" + feed.url + " <a href=\"\">[x]</a></li>"
  end

  def destroy_feed  
    feed = Feed.find(:first, :conditions => ["id = ? AND user_id = ?", params[:id], session[:user]])
    feed.destroy
    redirect_to :action => 'edit'
  end
  
  def show
    @user = User.find_by_id(params[:id]) 
  end
  
  def edit
    @user = User.find_by_id(session[:user])  
  end

  def nodes
    @user = User.find_by_id(params[:id]) 
    @nodes = Node.find(:all, :conditions => ["user_id = ?", @user.id])

    @user.feeds.each do |feed|
      feedReader = Reader.new(feed.url)
      feedReader.getFeeds().each do |f|
        @nodes << Node.new(f)
        
      end
    end
  end
  
  def destroy
    @user = User.find_by_id(session[:user])
    @user.deleted = true
    @user.save
  end
  
end
