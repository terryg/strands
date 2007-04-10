class XmlController < NodesController
  session :off

  NORMALIZED_FORMAT_FOR = {'atom' => 'atom10', 'rss' => 'rss20',
    'atom10' => 'atom10', 'rss20' => 'rss20',
    'googlesitemap' => 'googlesitemap' }

  CONTENT_TYPE_FOR = { 'rss20' => 'application/xml',
    'atom10' => 'application/atom+xml',
    'googlesitemap' => 'application/xml' }


  def feed
    @items = Array.new
    @format = params[:format]

    if @format == 'atom03'
      headers["Status"] = "301 Moved Permanently"
      return redirect_to(:format=>'atom')
    end

    @feed_title = "strnds.com"
    @link = "http://www.strnds.com"

    @format = NORMALIZED_FORMAT_FOR[@format]

    if not @format
      render :text => 'Unsupported format', :status => 404
      return
    end

    headers["Content-Type"] = "#{CONTENT_TYPE_FOR[@format]}; charset=utf-8"

    if respond_to?("prep_#{params[:type]}")
      self.send("prep_#{params[:type]}")
    else
      render :text => 'Unsupported action', :status => 404
      return
    end

    render :action => "#{@format}_feed"
  end

  def itunes
    @feed_title = "#{Strands} Podcast"
    @items = Resource.find(:all, :order => 'created_at DESC',
      :conditions => ['itunes_metadata = ?', true], :limit => 25)
    render :action => "itunes_feed"
  end

  def articlerss
    redirect_to :action => 'feed', :format => 'rss20', :type => 'article', :id => params[:id]
  end

  def commentrss
    redirect_to :action => 'feed', :format => 'rss20', :type => 'comments'
  end
  def trackbackrss
    redirect_to :action => 'feed', :format => 'rss20', :type => 'trackbacks'
  end

  def rsd
  end

  protected

  def fetch_items(association, order='start_date DESC', limit=nil)
    if association.instance_of?(Symbol)
      association = this_blog.send(association)
    end
    limit ||= 25
    @items += association.find_already_published(:all, :limit => limit, :order => order)
  end

  def prep_feed
    fetch_items(:nodes)
  end

  def prep_comments
    fetch_items(:comments)
    @feed_title << " comments"
  end

  def prep_trackbacks
    fetch_items(:trackbacks)
    @feed_title << " trackbacks"
  end

  def prep_node
    node = this_blog.nodes.find(params[:id])
    fetch_items(node.comments, 'published_at DESC', 25)
    @items.unshift(node)
    @feed_title << ": #{node.title}"
    @link = node.permalink_url
  end

  def prep_tag
    tag = Tag.find_by_name(params[:id])
    fetch_items(tag.nodes)
    @feed_title << ": Tag #{tag.display_name}"
    @link = tag.permalink_url
  end

  def prep_sitemap
    fetch_items(:nodes, 'created_at DESC', 1000)
    fetch_items(:pages, 'created_at DESC', 1000)
    @items += Category.find_all_with_node_counters(1000)
    @items += Tag.find_all_with_node_counters(1000)
  end
end
