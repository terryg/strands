class Reader
  def initialize(url)
    response = open(url).read 
    @doc = REXML::Document.new(response) 
  end
  
  def getFeeds()
    titles = []
    links = []
    dates = []
    descriptions = []
    links = []
    nodes = []
    
    @doc.elements.each("rss/channel/item/title") { |element|
      titles << element.text
    }
    @doc.elements.each("rss/channel/item/link") { |element|
      links << element.text
    }
    @doc.elements.each("rss/channel/item/pubDate") { |element|
      dates << element.text
    }
    @doc.elements.each("rss/channel/item/description") { |element|
      descriptions << element.text
    }
    @doc.elements.each("rss/channel/item/link") { |element|
      links << element.text
    }
    
    count = 0
    titles.each {|title|
      nodes << {:label => titles[count], :start_date => dates[count], :body => descriptions[count], :static_url => links[count]}
      count += 1
    }
    
    return nodes
  end
end
