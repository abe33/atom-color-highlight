_ = require 'underscore-plus'
{CompositeDisposable, Disposable} = require 'event-kit'


class CanvasColorsElement extends HTMLElement
  createdCallback: ->
    @subscriptions = new CompositeDisposable

    @canvas = document.createElement('canvas')
    @context = @canvas.getContext('2d')

    @appendChild(@canvas)

  attach: ->
    requestAnimationFrame =>
      editorElement = atom.views.getView(@model.editor)
      editorRoot = editorElement.shadowRoot ? editorElement
      editorRoot.querySelector('.scroll-view')?.appendChild this

  detachedCallback: ->
    @attach() unless @model.isDestroyed()

  setModel: (@model) ->
    {@editor} = @model
    @editorElement = atom.views.getView(@editor)

    @subscriptions.add @model.onDidUpdateMarkers => @requestUpdate()
    @subscriptions.add @model.onDidDestroy => @destroy()

  destroy: ->
    @subscriptions.dispose()
    @parentNode?.removeChild(this)

  requestUpdate: ->
    return if @frameRequested

    @frameRequested = true
    requestAnimationFrame =>
      @update()
      @frameRequested = false

  update: ->
    startScreenRow = @editorElement.getFirstVisibleScreenRow()
    endScreenRow = @editorElement.getLastVisibleScreenRow()

    markers = @editor.findMarkers(type: 'color-highlight', intersectsScreenRowRange: [startScreenRow, endScreenRow])

    console.log(markers)

module.exports = CanvasColorsElement = document.registerElement 'canvas-colors', prototype: CanvasColorsElement.prototype

CanvasColorsElement.registerViewProvider = (modelClass) ->
  atom.views.addViewProvider modelClass, (model) ->
    element = new CanvasColorsElement
    element.setModel(model)
    element
