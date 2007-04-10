module NodesHelper
  
  def page_title
    return "strnds.com"
  end
  
  def page_header
    return ""
  end
  
  def set_headers
     headers["Content-Type"] = "text/html; charset=utf-8"
  end

  def with_map?
    @show_map
  end  
end
