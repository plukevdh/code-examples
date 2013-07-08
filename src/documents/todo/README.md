# ToDo Example App

## The Goal

Demonstrate how to break down a simple app into pieces responsible for the different functions the app needs to perform:
- Persistence
- Display
- State

## How to Run

Both the specs and the project itself are CoffeeScript, so you'll need to compile before being able to run. I've set this up so that all is needed for this is to run `coffee -wco build src`. This will compile the files and output them to a `build` folder. All the project html references this project directory structure.

For the Todo app, open up the index.html file.

To run the specs, open the SpecRunner.html file.

## Black-Box Libraries

- **BFG.coffee**: our helper library, akin to (and mostly stolen from) Underscore.js
- **handlebars.js and mustachio.coffee**: Templating framework + custom helper library
- **storage.coffee**: Super basic wrapper around HTML5 localStorage API