class NodesController < ApplicationController
  before_filter :login_required, :only => [ :new, :create, :edit, :update, :comment ]

  helper 'calendar'
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update, :comment ],
         :redirect_to => { :action => :list }

  def list
    @node_pages, @nodes = paginate :nodes, :per_page => 10
  end

  def read
    @node = Node.find(params[:id])  
    
    @map = GMap.new("map_div")
	@map.control_init(:large_map => false,:map_type => false)
    if not @node.geocode.nil?
  	  @map.center_zoom_init([@node.geocode.latitude,@node.geocode.longitude],12)
	  @map.overlay_init(GMarker.new([@node.geocode.latitude,@node.geocode.longitude],:title => @node.label, :info_window => @node.excerpt))
    end
    @show_map = true
  end

  def find_by_date
    @nodes = Node.find_all_by_date(params[:year], params[:month], params[:day])
    render_paginated_index
  end
  
  def new
    @node = Node.new
  end

  def create
    @node = Node.new(params[:node])
    @node.user_id = session[:user]
    @node.tag_list = params[:tag_list]    
    if @node.save
      flash[:notice] = 'Node was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @node = Node.find(params[:id])
  end

  def update
    @node = Node.find(params[:id])
    @node.tag_list = params[:tag_list]
    if @node.user_id == session[:user] and 
        @node.update_attributes(params[:node])
      flash[:notice] = 'Node was successfully updated.'
      redirect_to :action => 'read', :id => @node
    else
      render :action => 'edit'
    end
  end
  
  def comment_preview
    if params[:comment].blank? or params[:comment][:comment].blank?
      render :nothing => true
      return
    end

    set_headers
    @comment = this_blog.comments.build(params[:comment])
    @controller = self
  end

  # Receive comments to nodes
  def comment
    if request.post?
      begin
        @node = Node.find(params[:id])
        @comment = Comment.new(params[:comment])
        @comment.user_id = session[:user]
        
        @node.comments<< @comment
        @comment.save!

        redirect_to :action => 'read', :id => @node
      rescue ActiveRecord::RecordInvalid
        STDERR.puts @comment.errors.inspect
        render_error(@comment)
      end
    end
  end

  def destroy
    node = Node.find(params[:id])
    if node.user_id = session[:user]
      Node.find(params[:id]).destroy
    end
    redirect_to :action => 'list'
  end

  def render_paginated_index(on_empty = "No nodes found...")
    return error(on_empty) if @nodes.empty?

    @pages = Paginator.new self, @nodes.size, 25, params[:page]
    start = @pages.current.offset
    stop  = (@pages.current.next.offset - 1) rescue @nodes.size
    # Why won't this work? @articles.slice!(start..stop)
    @nodes = @nodes.slice(start..stop)
    render :action => 'index'
  end  
end
