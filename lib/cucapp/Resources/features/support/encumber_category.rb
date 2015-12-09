module Encumber

  class GUI
    def value_is_equal(xpath, value)

      if !value
        value = ""
      end

      result = command 'valueIsEqual', id_for_element(xpath), value
      raise "Value #{value} not found" if result["result"] != "OK"
    end

    def pop_up_button_can_scroll_up(xpath)
      result = command 'popUpButtonMenuCanScrollUp', id_for_element(xpath)

      if result["result"] != "OK"
        return false
      end

      return true
    end

    def pop_up_button_can_scroll_down(xpath)
      result = command 'popUpButtonMenuCanScrollDown', id_for_element(xpath)

      if result["result"] != "OK"
        return true
      end

      return false
    end

  end
end