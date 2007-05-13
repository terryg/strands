class StrandsController < ApplicationController
  
  layout 'default', :except => 'nodes, show_nodes, show'
   
  def index
    set_parameters
  end
  
  def time
    @time = params[:id]
    @nodes = Node.find(:all, :conditions => ["start_date = ?", @time], :order => "start_date") 
  end

  def show
    set_parameters

    @strand_names = [ params[:id] ]    
    session[:strand_names] = @strand_names
    
    render :action => 'show', :layout => 'show'
  end
  
  def show_nodes
    @nodes = Array.new
    
    Node.find_tagged_with(session[:strand_names]).each do |n|
      @nodes<< n unless @nodes.include?(n)
    end
  
    render :action => 'nodes', :layout => false
  end

  def nodes
    user = nil
    
    if logged_in?
      user = User.find(session[:user])
    end
      
    set_parameters
    
    @nodes = Array.new
    
    taggings = Tagging.find(:all, :select => "count(*), tag_id", :group => "tag_id", :order => "count(*) DESC", :limit => 20)
    for tagging in taggings
      Node.find_tagged_with(tagging.tag.name).each do |n|
        @nodes<< n unless @nodes.include?(n)
      end
    end
    
    render :action => 'nodes', :layout => false
  end
    
  def refresh_strand_graph
    set_parameters
    
    @strand_names = Array.new
    @node_hashes = Array.new
    
    tag = params[:id]
    nodes = Node.find_tagged_with(tag)
      
    @strand_names<< tag
    @node_hashes<< make_hash(nodes)
    
    do_graph
  end
  
  def refresh_graph  
    index_data
    
    do_graph
  end
   
  private 
  
  def set_parameters
    @width = 70
    
    if params[:range].nil?
     @range = @width
    else
     @range = params[:range].to_i
    end
    
    if params[:start].nil?
      @start = Time.now - 60*60*24*@range
    else
      @start = Time.parse(params[:start]) 
    end

    @interval = 60*60*24*@range/@width
    
    @end = @start +  60*60*24*@range
    if @end > Time.now
      @end = Time.now
    end
  end
  
  def make_hash(nodes)
    nhash = Hash.new
    
    for node in nodes
      curr = node.date
      if not nhash.key?(curr)
        nhash[curr] = Array.new
      end
      
      nhash[curr]<< node
    end
    
    return nhash
  end

  def index_data
    user = nil
    
    if logged_in?
      user = User.find(session[:user])
    end
      
    set_parameters
    
    @strand_names = Array.new
    @node_hashes = Array.new
    
    taggings = Tagging.find(:all, :select => "count(*), tag_id", :group => "tag_id", :order => "count(*) DESC", :limit => 20)
    for tagging in taggings
      nodes = Node.find_tagged_with(tagging.tag.name)

      inrange = Array.new
      
      nodes.each do |n|
        if n.start_date >= @start and n.start_date <= @end
          inrange<< n    
        end
      end
      
      @strand_names<< tagging.tag.name
      @node_hashes<< make_hash(inrange)
    end
      
    if not user.nil?
      nodes = Node.find(:all, :conditions => ["user_id = ?", user.id], :order => "start_date")
      @strand_names<< "You"
      @node_hashes<< make_hash(nodes)
    end
    
    nodes = Node.find(:all, :order => "start_date")

    @strand_names<< "Everyone"
    @node_hashes<< make_hash(nodes)
  end

  def do_graph
    chart = Ziya::Charts::Line.new

    dates = Array.new
        
    index = @start
    while index <= @end
      if 1 == index.mday
        dates<< index.strftime("%Y-%m-%d")
      else
        dates<< ""
      end
      index = index + @interval
    end
    
    vtext = Array.new
    vtext<< ""
    @strand_names.each do |n|
      vtext<< n
    end

    chart.add( :axis_value_text, vtext )
    chart.add( :axis_category_text, dates )
    
    count = @strand_names.size
    
    if logged_in?
      decrement = 3
    else
      decrement = 2
    end
    
    for n in 0..(count-decrement)
      nhash = @node_hashes[n]
      
      values = Array.new
      dates.each do |d|
        if nhash.key?(d)
          values<< (count - n)
        else
          values<< (count - n)
        end
      end
            
      chart.add( :series, @strand_names[n], values )
    end
    
    values = Array.new
    dates.each do |d|
      if @node_hashes[count-(decrement-1)].key?(d)
        values<< (count-(decrement-1))
       else
        values<< (count-(decrement-1))
      end
    end
      
    chart.add( :series, @strand_names[count-(decrement-1)], values )    
    
    if 3 == decrement
      values = Array.new
      dates.each do |d|
        if @node_hashes[count-(decrement-2)].key?(d)
          values<< (count-(decrement-2))
        else
          values<< (count-(decrement-2))
        end
      end
      
      chart.add( :series, @strand_names[count-(decrement-2)], values )    
    end
   
    chart.add( :user_data, :min, -1 )
    chart.add( :user_data, :max, count )
    chart.add( :theme, "strands" )
    
    render :xml => chart.to_xml
  end
  
end
