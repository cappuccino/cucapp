module Driver
  class WebDriver
    
    attr_reader :url
    
    def initialize()
      @url = "https://qacnaserver7.cnaqa.com:8443"
    end
    
    def sayHello()
      puts "Hello!"
    end
    
    def getURL()
      return @url
    end
    
  end 
end