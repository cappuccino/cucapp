# Welcome to Cuccap

## Introduction

Cucapp is an interface between Cucumber (see: http://cukes.info) and Cappuccino.

The Cappuccino application is served via thin and a small piece of code is injected.
This code connects back to your Cucumber script via AJAX requests

This code is based heavily on Brominet (see: http://github.com/textarcana/brominet)

Original Concept and Developer: Daniel Parnell (see: https://github.com/dparnell)


## Installation

To get started, download the current version of Cuccap:

    $ git clone git://github.com/cappuccino/cucapp.git (git)

Then install cucapp on your system:

    $ gem build cucapp.gemspec && gem install cucapp

The following gems are going to be installed:

- Cucumber
- Thin
- Nokogiri
- JSON
- Launchy


## Usage

#### Environement Variables

You can set different env variables to configure Cucapp :

- The env variable CUCAPP_PORT allows you to specify the port used by the server Thin.
- The env variable CUCAPP_APPDIRECTORY allows you to specify where is your Cappuccino application.
- The env variable CUCAPP_USEBUNDLE allows you to specify if you want to use or not the bundle of Cucapp (It means you need to jake Cucapp)
- The env variable CUCAPP_APPLOADINGMODE allows you to specify which mode of the app you want to test (build or debug)

#### Categories

Cucapp provides a Category (HelperCategories.j) who allows you to add a cucappIdentifier to your different responder in your Cappuccino application. You should include the Category in your Cappuccino application.
The cucappIdentifier can be used massivelly in the Cucumber features to get an easy access to a targeted element.

When launching Cucumber, Cucapp will try to load the file CucumberCategories.j. This file has to be located in features/support/CucumberCategories.j.
This category allows you to add new Cappuccino methods who can be called from the features of your test (for instance a method to check the color of a CPView).

#### Steps features

Cucapp provides a set of basic methods who can be called from Cucumber (take a look at encumber.rb and Cucumber.j). You should mainly used the following methods :

```ruby
    def simulate_left_click xpath, flags
    def simulate_dragged_click_view_to_view xpath1, xpath2, flags
    def simulate_right_click xpath, flags
    def simulate_keyboard_event charac, flags
    def simulate_scroll_wheel xpath, deltaX, deltaY, flags
````

Example of a step:

 ```ruby
I want to fill a form and send the informations do
  app.gui.wait_for                    "//CPTextField[cucappIdentifier='field-name']"
  app.gui.simulate_left_click         "//CPTextField[cucappIdentifier='field-name']", []
  app.gui.simulate_keyboard_event     "a", [$CPCommandKeyMask]
  app.gui.simulate_keyboard_event     $CPDeleteCharacter, []
  app.gui.simulate_keyboard_events    "my_new_name", []
  app.gui.simulate_keyboard_event     $CPTabCharacter , []
  app.gui.simulate_keyboard_events    "my_new_family_name_", []
  app.gui.simulate_left_click         "//CPButton[cucappIdentifier='button-send']", []
end
```

The rest is pure Cucumber, don't hesitate to take a look at their website ;) (see: http://cukes.info)