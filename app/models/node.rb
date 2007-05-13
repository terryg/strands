class Node < ActiveRecord::Base
  acts_as_taggable
  acts_as_commentable
  acts_as_geocodable :address => {:street => :address, :locality => :city, :region => :statecode, :postal_code => :postcode}
  
  belongs_to :user
  has_one :node_comment_statistic
    
  def date
    start_date.strftime("%Y-%m-%d")
  end

  def date_url
    start_date.strftime("%Y/%m/%d")
  end
  
  def permalink_url
    "/nodes/read/#{id}"
  end
  
  def permalink_url(anchor=nil, only_path=true)
    "/nodes/read/#{id}"
  end
  
  def trackback_url
   ""
  end
  
  def linked_to_nodes
    links = LinkedNode.find(:all, :conditions => ["from_node_id = ?", self.id])  
    links.collect{|l| l.to_node}
  end

  def linked_from_nodes
    links = LinkedNode.find(:all, :conditions => ["to_node_id = ?", self.id])  
    links.collect{|l| l.from_node}
  end
    
  # Count articles on a certain date
  def self.count_by_date(year, month = nil, day = nil, limit = nil)
    from, to = self.time_delta(year, month, day)
    Node.count(["start_date BETWEEN ? AND ?",
                   from, to])
  end

  # Find all articles on a certain date
  def self.find_all_by_date(year, month = nil, day = nil)
    from, to = self.time_delta(year, month, day)
    Node.find(:all, :conditions => ["start_date BETWEEN ? AND ?",
                                                 from, to])
  end

  # Find one article on a certain date
  def self.find_by_date(year, month, day)
    find_all_by_date(year, month, day).first
  end

  # Finds one article which was posted on a certain date and matches the supplied dashed-title
  def self.find_by_permalink(year, month, day, title)
    from, to = self.time_delta(year, month, day)
    find_published(:first,
                   :conditions => ['permalink = ? AND ' +
                                   'published_at BETWEEN ? AND ?',
                                   title, from, to ])
  end

  
  def published_comments
    return comments
  end
 
   def html(field = :all)
    if field == :all
      generate_html(:all, content_fields.map{|f| self[f].to_s}.join("\n\n"))
    elsif self.class.html_map(field)
      generate_html(field)
    else
      raise "Unknown field: #{field.inspect} in article.html"
    end
  end

 def location
  loc = ["?<br>? ?&nbsp;&nbsp;?", self[:address], self[:city], self[:statecode], self[:postcode]]
 end
 
 def excerpt
  self[:body].slice(0..64)
 end
 
  # Bloody rails reloading. Nasty workaround.
  def body=(newval)
    if self[:body] != newval
      # changed
      self[:body] = newval
    end
    self[:body]
  end

  def body_html
    typo_deprecated "Use html(:body)"
    html(:body)
  end

  def extended=(newval)
    if self[:extended] != newval
      # changed
      self[:extended] = newval
    end
    self[:extended]
  end

  def extended_html
    typo_deprecated "Use html(:extended)"
    html(:extended)
  end

  def self.html_map(field=nil)
    html_map = { :body => true, :extended => true }
    if field
      html_map[field.to_sym]
    else
      html_map
    end
  end

  def content_fields
    [:body, :extended]
  end

  # Generate HTML for a specific field using the text_filter in use for this
  # object.  The HTML is cached in the fragment cache, using the +ContentCache+
  # object in @@cache.
  def generate_html(field, text = nil)
    text ||= self[field].to_s
    # html = text_filter.filter_text_for_content(blog, text, self)
    html ||= text # just in case the filter puked
    html_postprocess(field,html).to_s
  end

  # Post-process the HTML.  This is a noop by default, but Comment overrides it
  # to enforce HTML sanity.
  def html_postprocess(field,html)
    html
  end

  # The default text filter.  Generally, this is the filter specified by blog.text_filter,
  # but comments may use a different default.
  def default_text_filter
   # blog.text_filter.to_text_filter
  end

  # Grab the text filter for this object.  It's either the filter specified by
  # self.text_filter_id, or the default specified in the blog object.
  def text_filter
    if self[:text_filter_id] && !self[:text_filter_id].zero?
      TextFilter.find(self[:text_filter_id])
    else
      default_text_filter
    end
  end

  # Set the text filter for this object.
  def text_filter=(filter)
    returning(filter.to_text_filter) { |tf| self.text_filter_id = tf.id }
  end
 
  def is_duration
    result = false
    if start_date == end_date
      result = true
    end
    return result
  end
         
  protected
  
  def self.time_delta(year, month = nil, day = nil)
    from = Time.mktime(year, month || 1, day || 1)

    to = from.next_year
    to = from.next_month unless month.blank?
    to = from + 1.day unless day.blank?
    to = to - 1 # pull off 1 second so we don't overlap onto the next day
    return [from, to]
  end
  
  validates_presence_of :label

  def after_create
    sql = "INSERT INTO node_comment_statistics (node_id, last_comment_created_at, last_comment_user_id, comment_count) VALUES (#{self.id}, '#{self.created_at}', #{self.user_id}, 0)"
    connection.execute(sql)
  end
    

  private
  
end
