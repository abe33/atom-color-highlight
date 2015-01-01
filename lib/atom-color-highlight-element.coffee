_ = require 'underscore-plus'
{CompositeDisposable, Disposable} = require 'event-kit'

MarkerView = require './marker-view'
DotMarkerView = require './dot-marker-view'

class AtomColorHighlightElement extends HTMLElement

  createdCallback: ->
    @selections = []
    @markerViews = {}
    @subscriptions = new CompositeDisposable

  setModel: (@model) ->
    {@editor} = @model
    @editorElement = atom.views.getView(@editor)

    @subscriptions.add @model.onDidUpdateMarkers (markers) =>
      @markersUpdated(markers)

    @subscriptions.add @editor.onDidDestroy => @editorDestroyed()
    @subscriptions.add @editor.onDidAddCursor => @requestSelectionUpdate()
    @subscriptions.add @editor.onDidRemoveCursor => @requestSelectionUpdate()
    @subscriptions.add @editor.onDidChangeCursorPosition => @requestSelectionUpdate()
    @subscriptions.add @editor.onDidAddSelection => @requestSelectionUpdate()
    @subscriptions.add @editor.onDidRemoveSelection => @requestSelectionUpdate()
    @subscriptions.add @editor.onDidChangeSelectionRange => @requestSelectionUpdate()

    @subscriptions.add atom.config.observe 'atom-color-highlight.hideMarkersInComments', => @rebuildMarkers()
    @subscriptions.add atom.config.observe 'atom-color-highlight.hideMarkersInStrings', => @rebuildMarkers()
    @subscriptions.add atom.config.observe 'atom-color-highlight.markersAtEndOfLine', => @rebuildMarkers()
    @subscriptions.add atom.config.observe 'atom-color-highlight.dotMarkersSize', => @rebuildMarkers()
    @subscriptions.add atom.config.observe 'atom-color-highlight.dotMarkersSpading', => @rebuildMarkers()
    @subscriptions.add atom.config.observe 'editor.lineHeight', => @rebuildMarkers()
    @subscriptions.add atom.config.observe 'editor.fontSize', => @rebuildMarkers()

    @updateSelections()

  editorDestroyed: -> @destroy()

  requestSelectionUpdate: ->
    return if @updateRequested

    @updateRequested = true
    requestAnimationFrame =>
      @updateRequested = false
      return if @editor.getBuffer().isDestroyed()
      @updateSelections()

  updateSelections: ->
    return if @markers?.length is 0

    selections = @editor.getSelections()

    viewsToBeDisplayed = _.clone(@markerViews)

    for id,view of @markerViews
      view.removeClass('selected')

      for selection in selections
        range = selection.getScreenRange()
        viewRange = view.getScreenRange()
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
      if @markerViews[marker.id]?
        delete markerViewsToRemoveById[marker.id]
        if useDots
          sortedMarkers.push @markerViews[marker.id]
      else
        if useDots
          markerView = new DotMarkerView({@editorElement, @editor, marker, markersByRows})
          sortedMarkers.push markerView
        else
          markerView = new MarkerView({@editorElement, @editor, marker})
        @appendChild(markerView.element)
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
      @markerViews[marker.id].remove() if @markerViews[marker.id]?

      if atom.config.get('atom-color-highlight.markersAtEndOfLine')
        markerView = new DotMarkerView({@editorElement, @editor, marker, markersByRows})
      else
        markerView = new MarkerView({@editorElement, @editor, marker})

      @appendChild(markerView.element)
      @markerViews[marker.id] = markerView

  destroyAllViews: ->
    @removeChild(@firstChild) while @firstChild
    @markerViews = {}

#    ######## ##       ######## ##     ## ######## ##    ## ########
#    ##       ##       ##       ###   ### ##       ###   ##    ##
#    ##       ##       ##       #### #### ##       ####  ##    ##
#    ######   ##       ######   ## ### ## ######   ## ## ##    ##
#    ##       ##       ##       ##     ## ##       ##  ####    ##
#    ##       ##       ##       ##     ## ##       ##   ###    ##
#    ######## ######## ######## ##     ## ######## ##    ##    ##

module.exports = AtomColorHighlightElement = document.registerElement 'atom-color-highlight', prototype: AtomColorHighlightElement.prototype

AtomColorHighlightElement.registerViewProvider = ->
  atom.views.addViewProvider require('./atom-color-highlight-model'), (model) ->
    element = new AtomColorHighlightElement
    element.setModel(model)
    element
