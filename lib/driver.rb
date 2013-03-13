module Driver
  class WebDriver
    
    attr_reader :url
    attr_reader :total
    
    def initialize()
#      @url = "https://qacnaserver7.cnaqa.com:8443"
#      @url = "https://mvdclnx20:8443"
      @url = "https://variable_ip:8443"
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
