require 'rubygems'
require 'logger'
require 'mysql'
#require 'mysql_api'

module Driver
  class WebDriver
    
    attr_reader :url
    attr_reader :total
    attr_reader :dbResult
    
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

    def getHost()
      host = @url.gsub /^http(s?):\/\//, ''
      host = host.gsub /:\d*$/, ''
      return host
    end

    def loadVM(vmloop, enterprise, domain, zone, subnet)
      puts "Starting to load #{vmloop} VMs to enterprise #{enterprise} under subnet #{subnet} from JMeter......\nIt may take a while......"
      dir = "/Users/Shared/Jenkins/Home/SharedWorkspace/jmeter/CNA_JMETER/bin"
      Dir.chdir("#{dir}") do
	output = `jmeter  -nt ALU/CNA_GUI_VM_LOADING.jmx -Denterprise_name=#{enterprise} -Ddomain_name=#{domain} -Dzone_name=#{zone} -Dsubnet_name=#{subnet} -Dvmloop=#{vmloop}&`
      end
    end

    def runSQL(database, sql)
      remote_host = getHost()
      db_user	  = "cnauser"
      db_pw	  = "cnapass"
      db_name	  = "cnadb"
      conn = Mysql.real_connect(remote_host,db_user,db_pw,db_name)
      res = conn.query "#{sql}"
      row = res.fetch_row
      return row 
    end

    def saveDBResult(result)
      @dbResult = result
    end

    def getDBResult()
      return @dbResult 
    end

    def getTotalNumIdentifier(entity)
      if (entity == "enterprise")
	return "field_total_NUEnterprisesViewController"  
      elsif (entity == "domain")
	return "field_total_NUDomainsViewController"
      elsif (entify == "zone")
	return "field_total_NUZonesViewController"
      elsif (entify == "subnet")
	return "field_total_NUSubnetsViewController"
      end
    end

  end    
end
