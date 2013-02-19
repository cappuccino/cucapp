require 'encumber'
require 'driver'
class Cucapp
  class ExpectationFailed < RuntimeError
  end

  attr_reader :warning_text
  attr_reader :gui
  attr_reader :driver

  def initialize
    @gui = Encumber::GUI.new
    @gui.launch
    @driver = Driver::WebDriver.new
  end

  def reset
    @gui.command 'restoreDefaults'
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
