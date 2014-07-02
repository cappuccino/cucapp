# Welcome to Cuccap

## Introduction

Cucapp is an interface between Cucumber and Cappuccino.

The Cappuccino application is served via thin and a small piece of code is injected.
This code connects back to your Cucumber script via AJAX requests

This code is based heavily on Brominet (see http://github.com/textarcana/brominet)

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
