_ = require 'underscore-plus'
{CompositeDisposable, Disposable} = require 'event-kit'

MarkerElement = require './marker-element'
DotMarkerElement = require './dot-marker-element'

class AtomColorHighlightElement extends HTMLElement

  createdCallback: ->
    @selections = []
    @markerViews = {}
    @subscriptions = new CompositeDisposable

  attach: ->
    requestAnimationFrame =>
      editorElement = atom.views.getView(@model.editor)
      editorRoot = editorElement.shadowRoot ? editorElement
      editorRoot.querySelector('.lines')?.appendChild this

  detachedCallback: ->
    @attach() unless @model.isDestroyed()

  setModel: (@model) ->
    {@editor} = @model
    @editorElement = atom.views.getView(@editor)

    @subscriptions.add @model.onDidUpdateMarkers (markers) =>
      @markersUpdated(markers)
    @subscriptions.add @model.onDidDestroy => @destroy()

    @subscriptions.add @editor.onDidAddCursor => @requestSelectionUpdate()
    @subscriptions.add @editor.onDidRemoveCursor => @requestSelectionUpdate()
    @subscriptions.add @editor.onDidChangeCursorPosition => @requestSelectionUpdate()
    @subscriptions.add @editor.onDidAddSelection => @requestSelectionUpdate()
    @subscriptions.add @editor.onDidRemoveSelection => @requestSelectionUpdate()
    @subscriptions.add @editor.onDidChangeSelectionRange => @requestSelectionUpdate()

    @subscriptions.add @editorElement.onDidAttach =>
      @updateSelections()
      @updateMarkers()

    @subscriptions.add atom.config.observe 'atom-color-highlight.hideMarkersInComments', => @rebuildMarkers()
    @subscriptions.add atom.config.observe 'atom-color-highlight.hideMarkersInStrings', => @rebuildMarkers()
    @subscriptions.add atom.config.observe 'atom-color-highlight.markersAtEndOfLine', => @rebuildMarkers()
    @subscriptions.add atom.config.observe 'atom-color-highlight.dotMarkersSize', => @rebuildMarkers()
    @subscriptions.add atom.config.observe 'atom-color-highlight.dotMarkersSpading', => @rebuildMarkers()
    @subscriptions.add atom.config.observe 'editor.lineHeight', => @rebuildMarkers()
    @subscriptions.add atom.config.observe 'editor.fontSize', => @rebuildMarkers()

    @updateSelections()

  requestSelectionUpdate: ->
    return if @updateRequested

    @updateRequested = true
    requestAnimationFrame =>
      @updateRequested = false
      return if @editor.getBuffer().isDestroyed()
      @updateSelections()

  updateSelections: ->
    return if @editor.displayBuffer.isDestroyed()
    return if @markers?.length is 0

    selections = @editor.getSelections()

    viewsToBeDisplayed = _.clone(@markerViews)

    for id,view of @markerViews
      view.removeClass('selected')

      for selection in selections
        range = selection.getScreenRange()
        viewRange = view.getScreenRange()

        continue unless viewRange? and range?

        if viewRange.intersectsWith(range)
          view.addClass('selected')
          delete viewsToBeDisplayed[id]

    view.show() for id,view of viewsToBeDisplayed

  # Tear down any state and detach
  destroy: ->
    @subscriptions.dispose()
    @destroyAllViews()
    @parentNode?.removeChild(this)

  getMarkerAt: (position) ->
    for id, view of @markerViews
      return view if view.marker.bufferMarker.containsPoint(position)

  removeMarkers: ->
    markerView.remove() for id, markerView of @markerViews
    @markerViews = {}

  markersUpdated: (@markers) ->
    markerViewsToRemoveById = _.clone(@markerViews)
    markersByRows = {}
    useDots = atom.config.get('atom-color-highlight.markersAtEndOfLine')
    sortedMarkers = []

    for marker in @markers
      continue unless marker?
      if @markerViews[marker.id]?
        delete markerViewsToRemoveById[marker.id]
        if useDots
          sortedMarkers.push @markerViews[marker.id]
      else
        if useDots
          markerView = @createDotMarkerElement(marker, markersByRows)
          sortedMarkers.push markerView
        else
          markerView = @createMarkerElement(marker)
        @appendChild(markerView)
        @markerViews[marker.id] = markerView

    for id, markerView of markerViewsToRemoveById
      delete @markerViews[id]
      markerView.remove()

    if useDots
      markersByRows = {}
      for markerView in sortedMarkers
        markerView.markersByRows = markersByRows
        markerView.updateNeeded = true
        markerView.clearPosition = true
        markerView.updateDisplay()

  rebuildMarkers: ->
    return unless @markers
    markersByRows = {}

    for marker in @markers
      continue unless marker?
      @markerViews[marker.id].remove() if @markerViews[marker.id]?

      if atom.config.get('atom-color-highlight.markersAtEndOfLine')
        markerView = @createDotMarkerElement(marker, markersByRows)
      else
        markerView = @createMarkerElement(marker)

      @appendChild(markerView)
      @markerViews[marker.id] = markerView

  updateMarkers: ->
    markerView.updateDisplay() for id,markerView of @markerViews

  destroyAllViews: ->
    @removeChild(@firstChild) while @firstChild
    @markerViews = {}

  createMarkerElement: (marker) ->
    element = new MarkerElement
    element.init({@editorElement, @editor, marker})
    element

  createDotMarkerElement: (marker, markersByRows) ->
    element = new DotMarkerElement
    element.init({@editorElement, @editor, marker, markersByRows})
    element

#    ######## ##       ######## ##     ## ######## ##    ## ########
#    ##       ##       ##       ###   ### ##       ###   ##    ##
#    ##       ##       ##       #### #### ##       ####  ##    ##
#    ######   ##       ######   ## ### ## ######   ## ## ##    ##
#    ##       ##       ##       ##     ## ##       ##  ####    ##
#    ##       ##       ##       ##     ## ##       ##   ###    ##
#    ######## ######## ######## ##     ## ######## ##    ##    ##

module.exports = AtomColorHighlightElement = document.registerElement 'atom-color-highlight', prototype: AtomColorHighlightElement.prototype

AtomColorHighlightElement.registerViewProvider = (modelClass) ->
  atom.views.addViewProvider modelClass, (model) ->
    element = new AtomColorHighlightElement
    element.setModel(model)
    element
