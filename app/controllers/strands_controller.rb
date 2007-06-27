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
  
end
