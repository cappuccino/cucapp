require 'json'
require 'nokogiri'
require 'server'
require 'launchy'
require 'encumber'
require 'logger'

class VSDGUI < Encumber::GUI
  attr_reader :logger
  attr_reader :port

  def initialize(timeout_in_seconds, port)
    timeout_in_seconds = 30
    @timeout     = timeout_in_seconds
    @wait_element_timeout_in_loop = 5
    @port = port
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

  def launch
    sleep 0.2 # there seems to be a timing issue. This little hack fixes it.
    puts "Launch cucumber at port #{port}"
    Launchy.open("http://localhost:#{port}/cucumber.html")

    startTime = Time.now
    until command('launched') == "YES" || (Time.now-startTime<@timeout) do
      # do nothing
    end
    raise "launch timed out " if Time.now-startTime>@timeout

    sleep 1
  end
end

