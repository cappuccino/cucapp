# Copyright 2010, Daniel Parnell, Automagic Software Pty Ltd All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

require 'encumber'

class Cucapp
  class ExpectationFailed < RuntimeError
  end

  attr_reader :warning_text
  attr_reader :gui

  def initialize(*p)
    if p.has_key?("timeout_in_seconds")
      @gui = Encumber::GUI.new(p[:timeout_in_seconds])
    else 
      @gui = Encumber::GUI.new
    end
    if p.has_key?("url_params")
      @gui.launch(p[:url_params])
    else 
      @gui.launch
    end
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
