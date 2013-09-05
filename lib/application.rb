require 'encumber'
require 'driver'
require 'NUEncumber'
require 'logger'

class Cucapp
  class ExpectationFailed < RuntimeError
  end

  attr_reader :warning_text
  attr_reader :gui
  attr_reader :driver
  attr_reader :port
  attr_accessor :logger
  def initialize
    @driver = Driver::WebDriver.new
    @port = Driver::WebDriver.getPort
    @gui = VSDGUI.new(30, port)
    @gui.launch
  end

  def reset()
    @gui.command 'restoreDefaults'
  end

  def set_env(url, log)
    driver.setURL("#{url}")

    @logger = Logger.new("#{log}")
    logger.datetime_format = '%m-%d-%y %H:%M:%S'

  end

  def quit
    @gui.command 'closeBrowser'
  end

  def restart
    quit
    sleep 2
    @gui.launch
  end

end
