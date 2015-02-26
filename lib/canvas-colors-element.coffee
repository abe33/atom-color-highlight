_ = require 'underscore-plus'
{CompositeDisposable, Disposable} = require 'event-kit'
{ResizeDetection} = require 'atom-utils'

class CanvasColorsElement extends HTMLElement
  ResizeDetection.includeInto(this)

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

  attachedCallback: ->
    @canvas.width = @clientWidth * devicePixelRatio
    @canvas.height = @clientHeight * devicePixelRatio
    @initializeDOMPolling()

  resizeDetected: (width, height) ->
    @canvas.width = width * devicePixelRatio
    @canvas.height = height * devicePixelRatio
    @requestUpdate()

  detachedCallback: ->
    @attach() unless @model.isDestroyed()

  setModel: (@model) ->
    {@editor} = @model
    @editorElement = atom.views.getView(@editor)

    @subscriptions.add @model.onDidDestroy => @destroy()
    @subscriptions.add @model.onDidUpdateMarkers => @requestUpdate()

    @subscriptions.add @editor.onDidChangeScrollTop (e) => @requestUpdate()
    @subscriptions.add @editorElement.onDidAttach => @requestUpdate()

    @subscriptions.add atom.config.observe 'atom-color-highlight.hideMarkersInComments', =>
      @requestUpdate()
    @subscriptions.add atom.config.observe 'atom-color-highlight.hideMarkersInStrings', =>
      @requestUpdate()
    @subscriptions.add atom.config.observe 'atom-color-highlight.markersAtEndOfLine', =>
      @requestUpdate()
    @subscriptions.add atom.config.observe 'atom-color-highlight.dotMarkersSize', =>
      @requestUpdate()
    @subscriptions.add atom.config.observe 'atom-color-highlight.dotMarkersSpading', =>
      @requestUpdate()
    @subscriptions.add atom.config.observe 'editor.lineHeight', =>
      @requestUpdate()
    @subscriptions.add atom.config.observe 'editor.fontSize', =>
      @requestUpdate()

    @requestUpdate()

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

    @context.clearRect(0,0,@canvas.width, @canvas.height)

    @drawMarker(marker) for marker in markers

  drawMarker: (marker) ->
    {color, cssColor, textColor} = marker.getProperties()
    range = marker.getScreenRange()
    startPosition = @editor.pixelPositionForScreenPosition(range.start)
    endPosition = @editor.pixelPositionForScreenPosition(range.end)
    scrollTop = @editor.getScrollTop()

    lineHeight = @editor.getLineHeightInPixels()
    charWidth = @editor.getDefaultCharWidth()
    fontSize = atom.config.get('editor.fontSize')
    fontFamily = 'Monaco'#atom.config.get('editor.fontFamily')

    @context.fillStyle = cssColor
    rowSpan = range.end.row - range.start.row

    if rowSpan is 0
      colSpan = range.end.column - range.start.column
      @context.fillRect(startPosition.left, startPosition.top - scrollTop, endPosition.left - startPosition.left, lineHeight)

      @context.fillStyle = textColor
      @context.textBaseline = 'top'
      @context.font = "#{fontSize}px #{fontFamily}"
      @context.fillText(color, startPosition.left - charWidth, startPosition.top - scrollTop)
    else
      left = startPosition.left
      top = startPosition.top - scrollTop
      @context.fillRect(left,top,@canvas.width - left,lineHeight)
      @context.fillRect(0,top,@canvas.width, Math.max(rowSpan - 2, 0) * lineHeight)
      @context.fillRect(0,top,endPosition.left,lineHeight)

    @context.fill()

module.exports = CanvasColorsElement = document.registerElement 'canvas-colors', prototype: CanvasColorsElement.prototype

CanvasColorsElement.registerViewProvider = (modelClass) ->
  atom.views.addViewProvider modelClass, (model) ->
    element = new CanvasColorsElement
    element.setModel(model)
    element
