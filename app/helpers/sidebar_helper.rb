module SidebarHelper

  def render_sidebars
    sidebars = ""
    if logged_in?
      sidebars += "<ul>"
      sidebars += "  <li><a href=\"/user/edit\">my profile</a></li>"
      sidebars += "  <li><a href=\"/strands\">strands</a></li>"
      sidebars += "  <li><a href=\"/nodes/tracker\">tracker</a></li>"
      sidebars += "  <li><a href=\"timemap\">timemap</a></li>"
      sidebars += "  <li><a href=\"/logout\">logout</a></li>"
      sidebars += "</ul>"
    else
      sidebars += "<ul>"
      sidebars += "  <li><a href=\"/strands\">strands</a></li>"
      sidebars += "  <li><a href=\"/nodes/tracker\">tracker</a></li>"
      sidebars += "  <li><a href=\"timemap\">timemap</a></li>"
      sidebars += "  <li><a href=\"/login\">login</a></li>"
      sidebars += "</ul>"    
    end
    
    return sidebars
  end

  def render_sidebar(sidebar)

  end

end
