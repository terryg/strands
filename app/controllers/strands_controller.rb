class StrandsController < ApplicationController
  
  layout 'default', :except => 'nodes, show_nodes, show'
   
  def index
    @strands = Array.new
    
    taggings = Tagging.find(:all, :select => "count(*), tag_id", :group => "tag_id", :order => "count(*) DESC", :limit => 5)
    for tagging in taggings
      @strands<< tagging.tag.name
    end    
  end
  
  def time
    @time = params[:id]
    @nodes = Node.find(:all, :conditions => ["start_date = ?", @time], :order => "start_date") 
  end

  def show
    @strand_names = Array.new
    @strand_names<< params[:id]
    render :action => 'show', :layout => 'show'
  end 
  
  def show_nodes
    @nodes = Array.new
    
    Node.find_tagged_with(params[:id]).each do |n|
      @nodes<< n unless @nodes.include?(n)
    end
  
    render :action => 'nodes', :layout => false
  end
         
end
