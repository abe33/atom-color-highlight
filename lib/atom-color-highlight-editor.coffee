{Subscriber} = require 'emissary'
{CompositeDisposable} = require 'event-kit'

AtomColorHighlightModel = require './atom-color-highlight-model'
AtomColorHighlightView = require './atom-color-highlight-view'

module.exports =
class AtomColorHighlightEditor
  Subscriber.includeInto(this)

  constructor: (@editor) ->
    @subscriptions = new CompositeDisposable
    @editorElement = atom.views.getView(@editor)

    @model = null
    @view = null

    @subscriptions.add @editor.onDidChangePath @subscribeToBuffer
    @subscriptions.add @editor.getBuffer().onDidDestroy @destroy

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
      @view = new AtomColorHighlightView(@model, @editor, @editorElement)

      (@editorElement.shadowRoot ? @editorElement).querySelector('.lines').appendChild @view.element

      @model.init()

  unsubscribeFromBuffer: ->
    if @buffer?
      @removeModel()
      @removeView()
      @buffer = null

  removeView: -> @view?.destroy()

  removeModel: -> @model?.dispose()
