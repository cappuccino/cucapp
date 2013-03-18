module Driver
  class WebDriver
    
    attr_reader :url
    attr_reader :total
    
    def initialize()
      @url = "https://135.227.208.110:8443"
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
    
  end 
end
