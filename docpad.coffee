marked = require 'marked'
renderer = new marked.Renderer()
renderer.heading = (text, level) ->
  escapedText = text.toLowerCase().replace(/[^\w]+/g, '-')

  "<h#{level}><a name='#{escapedText}' class='anchor' href='##{escapedText}'>" +
    "<span class='header-link'>#{text}</span></a></h#{level}>"

# DocPad Configuration
docpadConfig = {
  regenerateDelay: 0
  watchOptions:
    catchupDelay: 0

  plugins:
    marked:
      markedOptions:
        renderer: renderer
        ghm: true
}

module.exports = docpadConfig