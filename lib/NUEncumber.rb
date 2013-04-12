require 'json'
require 'nokogiri'
require 'server'
require 'launchy'
require 'encumber'

class VSDGUI < Encumber::GUI
  def initialize(timeout_in_seconds=10)
  @timeout     = timeout_in_seconds
  @wait_element_timeout_in_loop = 5
  end

  def wait_for xpath
    wait_for_element xpath
  end

  def wait_for_element xpath
    start_time_for_wait = Time.now

    for i in 0..4
      elements                = dom_for_gui.search(xpath)
      return elements unless elements.empty?
      sleep @wait_element_timeout_in_loop
    end
    raise "Timeout for waiting Element #{xpath}...\n"
  end
end

