class StrandsController < ApplicationController
  layout 'default'
  
  def index
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
  
  def time
    @time = params[:id]
    @nodes = Node.find(:all, :conditions => ["start_date = ?", @time], :order => "start_date") 
  end

  def show
    set_parameters
    
    @strand_names = Array.new
    @node_hashes = Array.new
    
    tag = params[:id]
    nodes = Node.find_tagged_with(tag)
      
    @strand_names<< tag
    @node_hashes<< make_hash(nodes)
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
      if nhash[curr].nil?
        nhash[curr] = Array.new
      end
      
      nhash[curr]<< node
    end
    
    return nhash
  end
  
end
