Given /^the application is launched$/ do
  launched = app.gui.command "launched"

  if !launched
    raise "The application was not launched"
  end
end

Then /^I should see the label (.*)$/ do |value|
  app.gui.wait_for                    "//CPTextField[objectValue='Hello World!']"
  app.gui.value_is_equal              "//CPTextField[objectValue='Hello World!']", "Hello World!"
end