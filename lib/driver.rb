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

    def loadVM()
      puts "Starting to load VMs from JMeter...."
      dir = "/Users/Shared/Jenkins/Home/SharedWorkspace/jmeter/CNA_JMETER/bin"
      Dir.chdir("#{dir}") do
	output = `jmeter  -nt ALU/CNA_GUI_VM_FT.jmx&`
	puts output
      end

    end
    
  end
end
