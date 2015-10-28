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

require 'json'
require 'nokogiri'
require 'server'
require 'launchy'

$CPAlphaShiftKeyMask                     = 1 << 16;
$CPShiftKeyMask                          = 1 << 17;
$CPControlKeyMask                        = 1 << 18;
$CPAlternateKeyMask                      = 1 << 19;
$CPCommandKeyMask                        = 1 << 20;
$CPNumericPadKeyMask                     = 1 << 21;
$CPHelpKeyMask                           = 1 << 22;
$CPFunctionKeyMask                       = 1 << 23;
$CPDeviceIndependentModifierFlagsMask    = 0xffff0000;

$CPLeftMouseDownMask                     = 1 << 1;
$CPLeftMouseUpMask                       = 1 << 2;
$CPRightMouseDownMask                    = 1 << 3;
$CPRightMouseUpMask                      = 1 << 4;
$CPOtherMouseDownMask                    = 1 << 25;
$CPOtherMouseUpMask                      = 1 << 26;
$CPMouseMovedMask                        = 1 << 5;
$CPLeftMouseDraggedMask                  = 1 << 6;
$CPRightMouseDraggedMask                 = 1 << 7;
$CPOtherMouseDragged                     = 1 << 27;
$CPMouseEnteredMask                      = 1 << 8;
$CPMouseExitedMask                       = 1 << 9;
$CPCursorUpdateMask                      = 1 << 17;
$CPKeyDownMask                           = 1 << 10;
$CPKeyUpMask                             = 1 << 11;
$CPFlagsChangedMask                      = 1 << 12;
$CPAppKitDefinedMask                     = 1 << 13;
$CPSystemDefinedMask                     = 1 << 14;
$CPApplicationDefinedMask                = 1 << 15;
$CPPeriodicMask                          = 1 << 16;
$CPScrollWheelMask                       = 1 << 22;
$CPAnyEventMask                          = 0xffffffff;

$CPUpArrowFunctionKey                    = "\uF700";
$CPDownArrowFunctionKey                  = "\uF701";
$CPLeftArrowFunctionKey                  = "\uF702";
$CPRightArrowFunctionKey                 = "\uF703";
$CPF1FunctionKey                         = "\uF704";
$CPF2FunctionKey                         = "\uF705";
$CPF3FunctionKey                         = "\uF706";
$CPF4FunctionKey                         = "\uF707";
$CPF5FunctionKey                         = "\uF708";
$CPF6FunctionKey                         = "\uF709";
$CPF7FunctionKey                         = "\uF70A";
$CPF8FunctionKey                         = "\uF70B";
$CPF9FunctionKey                         = "\uF70C";
$CPF10FunctionKey                        = "\uF70D";
$CPF11FunctionKey                        = "\uF70E";
$CPF12FunctionKey                        = "\uF70F";
$CPF13FunctionKey                        = "\uF710";
$CPF14FunctionKey                        = "\uF711";
$CPF15FunctionKey                        = "\uF712";
$CPF16FunctionKey                        = "\uF713";
$CPF17FunctionKey                        = "\uF714";
$CPF18FunctionKey                        = "\uF715";
$CPF19FunctionKey                        = "\uF716";
$CPF20FunctionKey                        = "\uF717";
$CPF21FunctionKey                        = "\uF718";
$CPF22FunctionKey                        = "\uF719";
$CPF23FunctionKey                        = "\uF71A";
$CPF24FunctionKey                        = "\uF71B";
$CPF25FunctionKey                        = "\uF71C";
$CPF26FunctionKey                        = "\uF71D";
$CPF27FunctionKey                        = "\uF71E";
$CPF28FunctionKey                        = "\uF71F";
$CPF29FunctionKey                        = "\uF720";
$CPF30FunctionKey                        = "\uF721";
$CPF31FunctionKey                        = "\uF722";
$CPF32FunctionKey                        = "\uF723";
$CPF33FunctionKey                        = "\uF724";
$CPF34FunctionKey                        = "\uF725";
$CPF35FunctionKey                        = "\uF726";
$CPInsertFunctionKey                     = "\uF727";
$CPDeleteFunctionKey                     = "\uF728";
$CPHomeFunctionKey                       = "\uF729";
$CPBeginFunctionKey                      = "\uF72A";
$CPEndFunctionKey                        = "\uF72B";
$CPPageUpFunctionKey                     = "\uF72C";
$CPPageDownFunctionKey                   = "\uF72D";
$CPPrintScreenFunctionKey                = "\uF72E";
$CPScrollLockFunctionKey                 = "\uF72F";
$CPPauseFunctionKey                      = "\uF730";
$CPSysReqFunctionKey                     = "\uF731";
$CPBreakFunctionKey                      = "\uF732";
$CPResetFunctionKey                      = "\uF733";
$CPStopFunctionKey                       = "\uF734";
$CPMenuFunctionKey                       = "\uF735";
$CPUserFunctionKey                       = "\uF736";
$CPSystemFunctionKey                     = "\uF737";
$CPPrintFunctionKey                      = "\uF738";
$CPClearLineFunctionKey                  = "\uF739";
$CPClearDisplayFunctionKey               = "\uF73A";
$CPInsertLineFunctionKey                 = "\uF73B";
$CPDeleteLineFunctionKey                 = "\uF73C";
$CPInsertCharFunctionKey                 = "\uF73D";
$CPDeleteCharFunctionKey                 = "\uF73E";
$CPPrevFunctionKey                       = "\uF73F";
$CPNextFunctionKey                       = "\uF740";
$CPSelectFunctionKey                     = "\uF741";
$CPExecuteFunctionKey                    = "\uF742";
$CPUndoFunctionKey                       = "\uF743";
$CPRedoFunctionKey                       = "\uF744";
$CPFindFunctionKey                       = "\uF745";
$CPHelpFunctionKey                       = "\uF746";
$CPModeSwitchFunctionKey                 = "\uF747";
$CPEscapeFunctionKey                     = "\u001B";
$CPSpaceFunctionKey                      = "\u0020";

$CPEnterCharacter                        = "\u0003";
$CPBackspaceCharacter                    = "\u0008";
$CPTabCharacter                          = "\u0009";
$CPNewlineCharacter                      = "\u000a";
$CPFormFeedCharacter                     = "\u000c";
$CPCarriageReturnCharacter               = "\u000d";
$CPBackTabCharacter                      = "\u0019";
$CPDeleteCharacter                       = "\u007f";

$url_params                              = {};
$mouse_moved_activated                   = "yes"

module Encumber

  class GUI
    def initialize(timeout_in_seconds=10)
      @timeout     = timeout_in_seconds
      @global_x    = 0
      @global_y    = 0
    end

    def command(name, *params)
      raw = params.shift if params.first == :raw
      command = { :name => name, :params => params }

      #puts "command = #{command.inspect}"

      th = Thread.current
      response = nil
      data = nil
      CUCUMBER_REQUEST_QUEUE.push(command)
      CUCUMBER_RESPONSE_QUEUE.pop { |result|
          if result
              data = result['rack.input'].read
          end
          th.wakeup
      }
      startTime = Time.now
      sleep @timeout
      raise "Command timed out" if Time.now-startTime>=@timeout
      if data && !data.empty?
          obj = JSON.parse(data)
          if obj["error"]
              raise obj["error"]
          else
              begin
                  JSON.parse(obj["result"])
              rescue Exception => e
                  obj["result"]
              end
          end
      else
          nil
      end
    end

    def find(xpath)
      dom_for_gui.search(xpath)
    end

    def launch
      sleep 0.2 # there seems to be a timing issue. This little hack fixes it.
      Launchy.open("http://localhost:3000/cucumber.html" + self.make_url_params)

      startTime = Time.now

      while command('launched') == "NO" && (Time.now - startTime < @timeout) do
        # do nothing
      end

      raise "launch timed out " if Time.now-startTime>@timeout

      sleep 1
    end

    def make_url_params
      url = "?"

      $url_params.each_pair do |key, value|
          url = url + key + "=" + value + "&"
        end

      url
    end

    def quit
      command 'terminateApp'
      sleep 0.2
    end

    def dump
      command 'outputView'
    end

    def id_for_element(xpath)
      elements = dom_for_gui.search(xpath+"/id")
      raise "element not found: #{xpath}" if elements.empty?
      elements.first.inner_text.to_i
    end

    def points_for_element(xpath)
      x_elements = dom_for_gui.search(xpath+"/absoluteFrame/x")
      y_elements = dom_for_gui.search(xpath+"/absoluteFrame/y")
      width_elements = dom_for_gui.search(xpath+"/absoluteFrame/width")
      height_elements = dom_for_gui.search(xpath+"/absoluteFrame/height")
      raise "element not found: #{xpath}" if x_elements.empty?

      [x_elements.first.inner_text.to_f + width_elements.first.inner_text.to_f / 2 , y_elements.first.inner_text.to_f + height_elements.first.inner_text.to_f / 2]
    end

    def closeWindow(xpath)
      performRemoteAction('closeWindow', xpath)
    end

    def text_for(xpath)
      result = command "textFor", id_for_element(xpath)
      raise "Could not find text for element #{xpath}" if result['result'] == "__CUKE_ERROR__"
      result['result']
    end

    # Nokogiri XML DOM for the current Brominet XML representation of the GUI
    def dom_for_gui
      @dom = Nokogiri::XML self.dump
    end

    def wait_for xpath
      wait_for_element xpath
    end

    def wait_for_element xpath
      start_time_for_wait = Time.now

      loop do
        elements                = dom_for_gui.search(xpath)

        return elements unless elements.empty?

        # Important: get the elapsed time AFTER getting the gui and
        # evaluating the xpath.
        elapsed_time_in_seconds = Time.now - start_time_for_wait

        return nil if elapsed_time_in_seconds >= @timeout
      end
    end

    def move_mouse_to_point(x, y)

      if !$mouse_moved_activated
        return
      end

      x = x.round
      y = y.round

      if x == @global_x && y == @global_y
        return
      end

      i = 0;
      distance = Math.sqrt((x - @global_x) ** 2 + (y - @global_y) ** 2)
      step = 0.01

      if distance < 50
        step = 0.05
      end

      if distance > 50 && distance < 300
        step = 0.02
      end

      while i <= 1 do

        tmp_x = (1 - i) * @global_x + i * x
        tmp_y = (1 - i) * @global_y + i * y

        command('simulateMouseMovedOnPoint', tmp_x, tmp_y, [])

        i = i + step

      end

      command('simulateMouseMovedOnPoint', x, y, [])

      @global_x = x
      @global_y = y

    end

    def simulate_left_click(xpath, flags=[])
      points = points_for_element(xpath)
      move_mouse_to_point(points[0], points[1])

      result = command('simulateLeftClick', id_for_element(xpath), flags)
      raise "View not found: #{xpath} - #{result}" if result["result"] !='OK'
    end

    def simulate_left_click_on_point(x, y, flags=[])
      move_mouse_to_point(x, y)

      result = command('simulateLeftClickOnPoint', x, y, flags)
    end

    def simulate_double_click(xpath, flags=[])
      points = points_for_element(xpath)
      move_mouse_to_point(points[0], points[1])

      result = command('simulateDoubleClick', id_for_element(xpath), flags)
      raise "View not found: #{xpath} - #{result}" if result["result"] != 'OK'
    end

    def simulate_double_click_on_point(x, y, flags=[])
      move_mouse_to_point(x, y)

      result = command('simulateDoubleClick', x, y, flags)
    end

    def simulate_dragged_click_view_to_view(xpath1, xpath2, flags=[])
      points = points_for_element(xpath1)
      move_mouse_to_point(points[0], points[1])

      result = command('simulateDraggedClickViewToView', id_for_element(xpath1), id_for_element(xpath2), flags)
      raise "View not found: #{xpath1} or #{xpath2}- #{result}" if result["result"] != 'OK'

      points = points_for_element(xpath2)
      @global_y = points[0]
      @global_x = points[1]
    end

    def simulate_dragged_click_view_to_point(xpath1, x, y, flags=[])
      points = points_for_element(xpath1)
      move_mouse_to_point(points[0], points[1])

      result = command('simulateDraggedClickViewToPoint', id_for_element(xpath1), x, y, flags)
      raise "View/Point not found: #{xpath1} - #{result}" if result["result"] != 'OK'

      @global_y = x
      @global_x = y
    end

    def simulate_dragged_click_point_to_point(x, y, x2, y2, flags=[])
      move_mouse_to_point(x, y)
      result = command('simulateDraggedClickPointToPoint', x, y, x2, y2, flags)

      @global_y = x2
      @global_x = y2
    end

    def simulate_right_click(xpath, flags=[])
      points = points_for_element(xpath)
      move_mouse_to_point(points[0], points[1])

      result = command('simulateRightClick', id_for_element(xpath), flags)
      raise "View not found: #{xpath} - #{result}" if result["result"] != 'OK'
    end

    def simulate_right_click_on_point(x, y, flags=[])
      move_mouse_to_point(x, y)

      result = command('simulateRightClickOnPoint', x, y, flags)
    end

    def simulate_mouse_moved_on_point(x, y, flags=[])
      move_mouse_to_point(x, y)

      result = command('simulateMouseMovedOnPoint', x, y, flags)
    end

    def simulate_keyboard_event(charac, flags=[])
      result = command('simulateKeyboardEvent', charac, flags)
    end

    def simulate_keyboard_events(string, flags=[])
      string.to_s.split("").each do |c|
        result = command('simulateKeyboardEvent', c, flags)
      end
    end

    def simulate_scroll_wheel(xpath, deltaX, deltaY, flags=[])
      points = points_for_element(xpath)
      move_mouse_to_point(points[0], points[1])

      result = command('simulateScrollWheel',id_for_element(xpath), deltaX, deltaY, flags)
      raise "View not found: #{xpath} - #{result}" if result["result"] != 'OK'
    end

  end
end
