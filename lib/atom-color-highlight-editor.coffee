{Subscriber} = require 'emissary'
{CompositeDisposable} = require 'event-kit'

AtomColorHighlightModel = require './atom-color-highlight-model'
AtomColorHighlightView = require './atom-color-highlight-view'

module.exports =
class AtomColorHighlightEditor
  Subscriber.includeInto(this)

  constructor: (@editorView) ->
    {@editor} = @editorView

    @subscriptions = new CompositeDisposable

    @model = null
    @view = null

    @subscriptions.add @editorView.getModel().onDidChangePath @subscribeToBuffer
    @subscriptions.add @editorView.getModel().getBuffer().onDidDestroy @destroy

    @subscribeToBuffer()

  getActiveModel: -> @model

  getActiveView: -> @view

  destroy: =>
    @unsubscribe()
    @unsubscribeFromBuffer()

  subscribeToBuffer: =>
    @unsubscribeFromBuffer()

    if @buffer = @editor.getBuffer()
      @model = new AtomColorHighlightModel(@editor, @buffer)
      @view = new AtomColorHighlightView(@model, @editorView)

      if atom.config.get('core.useReactEditor')
        @editorView.find('.lines').append @view
      else
        @editorView.overlayer.append @view

      @model.init()

  unsubscribeFromBuffer: ->
    if @buffer?
      @removeModel()
      @removeView()
      @buffer = null

  removeView: -> @view?.destroy()

  removeModel: -> @model?.dispose()
