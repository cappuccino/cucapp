module Driver
  class WebDriver
    
    attr_reader :url
    attr_reader :total
    attr_reader :site
    
    def initialize()
    end
    
    def setTotal(total)
      @total = total
    end
    
    def getTotal()
      return @total
    end
    
    def getURL()
      return @url
    end

    def setURL(site)
	@url = "https://#{site}:8443"
    end 
  end
end
