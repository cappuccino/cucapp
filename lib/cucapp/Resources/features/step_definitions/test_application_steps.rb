Given /^the application is launched$/ do
  launched = app.gui.command "launched"

  if !launched
    raise "The application was not launched"
  end
end

When /^I hit the key (.*)$/ do |value|
  app.gui.simulate_keyboard_event    value, []
end

When /^I hit the keys (.*)$/ do |value|
  app.gui.simulate_keyboard_events    value, []
end

When /^I hit select all$/ do
  app.gui.simulate_keyboard_event    "a", [$CPCommandKeyMask]
end

When /^I hit delete$/ do
  app.gui.simulate_keyboard_event    $CPDeleteCharacter, []
end

When /^I hit tab$/ do
  app.gui.simulate_keyboard_event    $CPTabCharacter, []
end

When /^I hit shift tab$/ do
  app.gui.simulate_keyboard_event    $CPTabCharacter, [$CPShiftKeyMask]
end

When /^I hit escape $/ do
  app.gui.simulate_keyboard_event    $CPEscapeFunctionKey, []
end

When /^I hit enter $/ do
  app.gui.simulate_keyboard_event    $CPNewlineCharacter, []
end

When /^I hit on the left arrow $/ do
  app.gui.simulate_keyboard_event    $CPLeftArrowFunctionKey, []
end

When /^I hit on the up arrow $/ do
  app.gui.simulate_keyboard_event    $CPUpArrowFunctionKey, []
end

When /^I hit on the down arrow $/ do
  app.gui.simulate_keyboard_event    $CPDownArrowFunctionKey, []
end

When /^I hit on the right arrow $/ do
  app.gui.simulate_keyboard_event    $CPRightArrowFunctionKey, []
end

When /^I click on the control (.*)$/ do |cucappIdentifier|
  app.gui.wait_for                    "//CPTextField[cucappIdentifier='#{cucappIdentifier}']"
  app.gui.simulate_left_click         "//CPTextField[cucappIdentifier='#{cucappIdentifier}']", []
end

When /^I double click on the control (.*)$/ do |cucappIdentifier|
  app.gui.wait_for                    "//CPTextField[cucappIdentifier='#{cucappIdentifier}']"
  app.gui.simulate_double_click       "//CPTextField[cucappIdentifier='#{cucappIdentifier}']", []
end

Then /^I should see the control with the value (.*)$/ do |value|
  app.gui.wait_for                    "//CPTextField[objectValue='#{value}']"
  app.gui.value_is_equal              "//CPTextField[objectValue='#{value}']", "#{value}"
end