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

    @subscribe @editorView, 'editor:will-be-removed', @destroy

  getActiveModel: ->
    path = @buffer.getPath()
    @models[path]

  getActiveView: ->
    path = @buffer.getPath()
    @views[path]

  destroy: =>
    @unsubscribe()
    @unsubscribeFromBuffer()

  subscribeToBuffer: =>
    @unsubscribeFromBuffer()

    if @buffer = @editor.getBuffer()
      model = @models[@buffer.getPath()] =
        new AtomColorHighlightModel(@editor, @buffer)

      view = @views[@buffer.getPath()] =
        new AtomColorHighlightView(model, @editorView)

      if atom.config.get('core.useReactEditor')
        @editorView.find('.lines').append view
      else
        @editorView.overlayer.append view

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
