module Encumber
  class GUI

    def value_is_equal(xpath, value)
      result = command 'valueIsEqual', id_for_element(xpath), value
      raise "Value #{value} not found" if result["result"] != "OK"
    end

  end
end