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
    timeout_in_seconds, url_params = *p
    if timeout_in_seconds.nil?
      @gui = Encumber::GUI.new
    else
      @gui = Encumber::GUI.new(timeout_in_seconds)
    end
    if url_params.nil?
      @gui.launch
    else
      @gui.launch(url_params)
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
