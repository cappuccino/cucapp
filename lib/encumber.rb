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

module Encumber

  class GUI
    def initialize(timeout_in_seconds=10)
      @timeout     = timeout_in_seconds
    end

    def command(name, *params)
      raw = params.shift if params.first == :raw
      command = { :name => name, :params => params }

      #puts "command = #{command.inspect}"

      th = Thread.current
      response = nil
      CUCUMBER_REQUEST_QUEUE.push(command)
      CUCUMBER_RESPONSE_QUEUE.pop { |result|
#        puts "RESPONSE: #{result}"
        response = result
        th.wakeup
      }
      startTime = Time.now
      sleep @timeout
      raise "Command timed out" if Time.now-startTime>=@timeout

      if response
        data = response['rack.input'].read

        if data && !data.empty?
          obj = JSON.parse(data)

          if obj["error"]
            raise obj["error"]
          else
            obj["result"]
          end
        else
          nil
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
      Launchy.open("http://localhost:3000/cucumber.html")

      startTime = Time.now
      until command('launched') == "YES" || (Time.now-startTime<@timeout) do
        # do nothing
      end
      raise "launch timed out " if Time.now-startTime>@timeout

      sleep 1
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

    def performRemoteAction(action, xpath)
      result = command action, id_for_element(xpath)

      raise "View not found: #{xpath}" if result!='OK'
    end

    def press(xpath)
      performRemoteAction('simulateTouch', xpath)
    end

    def performMenuItem(xpath)
      performRemoteAction('performMenuItem', xpath)
    end

    def closeWindow(xpath)
      performRemoteAction('closeWindow', xpath)
    end

    def select_from(value_to_select, xpath)
      result = command 'selectFrom', value_to_select, id_for_element(xpath)

      raise "Could not select #{value_to_select} in #{xpath} " + result if result != "OK"
    end

    def select_menu(menu_item)
      result = command 'selectMenu', menu_item

      raise "Could not select #{menu_item} from the menu" + result if result != "OK"
    end

    def fill_in(value, xpath)
      type_in_field value, xpath
    end

    def find_in(value, xpath)
      result = command "findIn", value, id_for_element(xpath)

      raise "Could not find #{value} in #{xpath}" if result != "OK"

      result == "OK"
    end

    def text_for(xpath)
      result = command "textFor", id_for_element(xpath)

      raise "Could not find text for element #{xpath}" if result == "__CUKE_ERROR__"

      result
    end

    def double_click(value, xpath)
      result = command 'doubleClick', id_for_element(xpath)

      raise "Could not double click #{xpath}" if result != "OK"
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

    def type_in_field text, xpath
      result = command('setText', text, id_for_element(xpath))
      raise "View not found: #{xpath} - #{result}" if result!='OK'
      sleep 1
    end

    def tap xpath
      press xpath
    end

    def tap_and_wait xpath
      press xpath
      sleep 1
    end

    def simulateLeftClick xpath, flags
      result = command('simulateLeftClick', id_for_element(xpath), flags)
      raise "View not found: #{xpath} - #{result}" if result!='OK'
    end

    def simulateDoubleClick xpath, flags
      result = command('simulateDoubleClick', id_for_element(xpath), flags)
      raise "View not found: #{xpath} - #{result}" if result!='OK'
    end

    def simulateDraggedClick xpath1, xpath2, flags
      result = command('simulateDraggedClick', id_for_element(xpath), id_for_element(xpath2), flags)
      raise "View not found: #{xpath} or #{xpath2}- #{result}" if result!='OK'
    end

    def simulateRightClick xpath, flags
      result = command('simulateRightClick', id_for_element(xpath), flags)
      raise "View not found: #{xpath} - #{result}" if result!='OK'
    end

    def simulateKeyboardEvent charac, flags
      result = command('simulateKeyboardEvent', charac, flags)
    end

    def simulateKeyboardEvents string, flags
      string.split("").each do |c|
        result = command('simulateKeyboardEvent', c, flags)
        sleep(0.1)
      end
    end

  end
end