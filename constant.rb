module Constant
    class Constant
	attr_reader :default_url
	attr_reader :default_log
	
	def initialize()
	    @default_url="https://mvdclnx22.cnaqa.eng.timetra.com:8443"
	    @default_log="/Users/Shared/Jenkins/Home/SharedWorkspace/cucumber_logs/automation.log"
	end
    end
end

