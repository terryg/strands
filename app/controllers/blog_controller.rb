class BlogController < ApplicationController

  layout 'nodes'

  
  def index
   @nodes = Node.find(:all,
                      :order => "node_comment_statistics.last_comment_created_at DESC",
                      :include => :node_comment_statistic)
   render_paginated_index
  end

  def user
    user = User.find(:first, :conditions => ["login = ?", params[:id]])

    @nodes = Node.find(:all,
                       :conditions => ["user_id = ?", user.id],
                       :order => "node_comment_statistics.last_comment_created_at DESC",
                       :include => :node_comment_statistic)
    render_paginated_index
  end

  protected

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
