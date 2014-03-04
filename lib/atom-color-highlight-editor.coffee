{Subscriber} = require 'emissary'

AtomColorHighlightModel = require './atom-color-highlight-model'
AtomColorHighlightView = require './atom-color-highlight-view'

module.exports =
class AtomColorHighlightEditor
  Subscriber.includeInto(this)

  constructor: (@editorView) ->
    {@editor} = @editorView

    @models = {}
    @views = {}

    @subscribe @editorView, 'editor:path-changed', @subscribeToBuffer

    @subscribeToBuffer()

    @subscribe @editorView, 'editor:will-be-removed', =>
      @unsubscribe()
      @unsubscribeFromBuffer()

  subscribeToBuffer: =>
    @unsubscribeFromBuffer()

    if @buffer = @editor.getBuffer()
      model = @models[@buffer.getPath()] =
        new AtomColorHighlightModel(@editor, @buffer)

      view = @views[@buffer.getPath()] =
        new AtomColorHighlightView(model, @editorView)

      @editorView.underlayer.append view

      model.init()


  unsubscribeFromBuffer: ->
    if @buffer?
      @removeModel()
      @removeView()
      @buffer = null

  removeView: ->
    path = @buffer.getPath()
    @views[path]?.destroy()
    delete @views[path]

  removeModel: ->
    path = @buffer.getPath()
    @models[path]?.dispose()
    delete @models[path]
