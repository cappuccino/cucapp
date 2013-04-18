require 'logger'

module Driver
  class WebDriver
    
    attr_reader :url
    attr_reader :total
    
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
    
    def setURL(url)
	@url = "#{url}"
    end 
    
  end
end
