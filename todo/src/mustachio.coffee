class Mustachio
  templates: {}

  constructor: (@model) ->

  render: ->
    @templates[@templateName].call @, @renderContext()

  lazyCompileFactory: (template_id, raw_template) ->
    @templates[template_id] = (context) =>
      compiled_template = Handlebars.compile(raw_template)
      @templates[this.id] = compiled_template
      compiled_template(context)

  renderContext: ->
    if @model then @model.toJSON() else {}

  @prepare = ->
    $('script[type="text/x-handlebars-template"]').each (i, item) =>
      raw_template = item.textContent
      raw_template = item.innerHTML unless raw_template   # IE 8

      @::lazyCompileFactory(item.id, raw_template)

window.Mustachio = Mustachio

$ ->
  Mustachio.prepare()