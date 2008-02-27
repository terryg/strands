class TimemapController < ApplicationController
  layout 'default', :except => 'index'

  def index
    @nodes = Array.new
    nodes = Node.find(:all, :conditions => "start_date is not null")
    nodes.each do |n|
      if n.geocode != nil
        @nodes << n
      end
    end
  end

end