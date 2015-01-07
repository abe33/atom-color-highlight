{Emitter} = require 'event-kit'
{deprecate} = require 'grim'
[AtomColorHighlightModel, AtomColorHighlightElement] = []

class AtomColorHighlight
  config:
    markersAtEndOfLine:
      type: 'boolean'
      default: false
    hideMarkersInComments:
      type: 'boolean'
      default: false
    hideMarkersInStrings:
      type: 'boolean'
      default: false
    dotMarkersSize:
      type: 'number'
      default: 16
      min: 2
    dotMarkersSpacing:
      type: 'number'
      default: 4
      min: 0
    excludedGrammars:
      type: 'array'
      default: []
      description: "Prevents files matching the specified grammars scopes from having their colors highligted. Changing this setting may need a restart to take effect. This setting takes a list of scope strings separated with commas. Scope for a grammar can be found in the corresponding package description in the settings view."
      items:
        type: 'string'

  models: {}

  activate: (state) ->
    AtomColorHighlightModel ||= require './atom-color-highlight-model'
    AtomColorHighlightElement ||= require './atom-color-highlight-element'
    @Color ||= require 'pigments'

    AtomColorHighlightElement.registerViewProvider(AtomColorHighlightModel)
    AtomColorHighlightModel.Color = @Color

    unless atom.inSpecMode()
      try atom.packages.activatePackage('project-palette-finder').then (pack) =>
        finder = pack.mainModule
        AtomColorHighlightModel.Color = @Color = finder.Color if finder?
        @subscriptions.add finder.onDidUpdatePalette @update

    @emitter = new Emitter
    atom.workspace.observeTextEditors (editor) =>

      return if editor.getGrammar().scopeName in atom.config.get('atom-color-highlight.excludedGrammars')

      model = new AtomColorHighlightModel(editor)
      view = atom.views.getView(model)

      model.init()
      view.attach()

      model.onDidDestroy => delete @models[editor.id]

      @models[editor.id] = model
      @emitter.emit 'did-create-model', model

  eachColorHighlightEditor: (callback) ->
    deprecate 'Use ::observeColorHighlightModels instead'
    @observeColorHighlightModels(callback)

  observeColorHighlightModels: (callback) ->
    callback?(editor) for id,editor of @models if callback?
    @onDidCreateModel(callback)

  onDidCreateModel: (callback) ->
    @emitter.on 'did-create-model', callback

  modelForEditor: (editor) -> @models[editor.id]

  deactivate: ->
    model.destroy() for id,model of @models
    @models = {}

module.exports = new AtomColorHighlight
