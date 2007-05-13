# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include SidebarHelper
  
  def page_title
    return "strnds.com"
  end
  
  def page_header
<<-EOL
<script src="http://simile.mit.edu/timeline/api/timeline-api.js" type="text/javascript"></script>
<script src="/javascripts/application.js" type="text/javascript"></script>
EOL
  end
 
  # Produce a link to the permalink_url of 'item'.
  def link_to_permalink(item, title, anchor=nil)
    anchor = "##{anchor}" if anchor
    "<a href=\"#{item.permalink_url}#{anchor}\">#{title}</a>"
  end

  def author_link(node)
    node.user.login
  end

  # The '5 comments' link from the bottom of nodes
  def comments_link(node)
    link_to_permalink(node,pluralize(node.published_comments.size, 'comment'),'comments')
  end
  
  def tag_links(node)
    "Tags " + node.tags.map { |tag| link_to tag.display_name, tag.permalink_url, :rel => "tag"}.sort.join(", ")
  end
 
  def js_distance_of_time_in_words_to_now(date)
    if date
      time = date.utc.strftime("%a, %d %b %Y %H:%M:%S GMT") 
    else
      time = Time.now
    end
      "<span class=\"typo_date\" title=\"#{time}\">#{time}</span>" 
  end
      
  def display_dateline(start, endd, interval)
    strand = ""
    ticks = ""
    index = start
      
    last = index.mon
    
    tick = "<div style=\"visibility:hidden; display:inline\">-</div>"
    first = false
    while index <= endd
      curr = index.mon
      
      if 1 == index.mday || last != curr
        strand += "|"
        if ticks.size > (3 * tick.size)
          if first
            ticks.slice!(-4 * tick.size, 3 * tick.size)
          end

          ticks.slice!(-4 * tick.size, 3 * tick.size)
          ticks += index.strftime("%Y-%m")
          first = true
        else
          ticks += tick
        end
        
        last = curr
      else
       strand += "-"
       ticks += tick
      end
      
      index = index + interval
    end
<<-EOL
<tr>
<td></td>
<td></td>
<td><strong>#{ strand }</strong></td>
</tr>
<tr>
<td></td>
<td></td>
<td><strong>#{ ticks }</strong></td>
</tr>
EOL
  end
  
  def display_strand(title, start, endd, interval, nhash, link_title = true)
    strand = ""
    index = start
    
    strand_name = ""
    if link_title
      strand_name += "<a href=\"/strands/show/#{title}\" style=\"text-decoration:none\">#{title}</a>" 
    else
      strand_name += "#{title}"
    end

    while index <= endd
      curr = index.strftime("%Y-%m-%d")
       
      if not nhash[curr].nil?
        node = nhash[curr][0]
        if 1 == nhash[curr].size
          strand += "<a href=\"/nodes/read/#{ node.id }\" title=\"#{ node.label }\" border=\"0\" style=\"text-decoration:none\">o</a>"
        else
          strand += "<a href=\"/nodes/#{ node.date_url }\" title=\"#{ node.date }\" border=\"0\" style=\"text-decoration:none\">*</a>"
        end
      else
       strand += "-"
      end
 
      index = index + interval
    end
<<-EOL
<tr>
<td> 
<strong>
#{strand_name}
</strong>
<td> 
</td>
<td>
<strong>
#{ strand }
</strong>
</td>
</tr>
EOL
  end
  
end
