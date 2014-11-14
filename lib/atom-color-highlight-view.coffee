_ = require 'underscore-plus'
{View, $} = require 'atom'
{Subscriber} = require 'emissary'
{CompositeDisposable, Disposable} = require 'event-kit'

MarkerView = require './marker-view'
DotMarkerView = require './dot-marker-view'

module.exports =
class AtomColorHighlightView extends View
  Subscriber.includeInto(this)

  @content: ->
    @div class: 'atom-color-highlight'

  constructor: (model, editorView) ->
    super
    @selections = []
    @markerViews = {}

    @subscriptions = new CompositeDisposable

    @observeConfig()
    @setEditorView(editorView)
    @setModel(model)

    @updateSelections()

  observeConfig: ->
    @subscriptions.add @asDisposable atom.config.observe 'atom-color-highlight.hideMarkersInComments', @rebuildMarkers
    @subscriptions.add @asDisposable atom.config.observe 'atom-color-highlight.hideMarkersInStrings', @rebuildMarkers
    @subscriptions.add @asDisposable atom.config.observe 'atom-color-highlight.markersAtEndOfLine', @rebuildMarkers
    @subscriptions.add @asDisposable atom.config.observe 'atom-color-highlight.dotMarkersSize', @rebuildMarkers
    @subscriptions.add @asDisposable atom.config.observe 'atom-color-highlight.dotMarkersSpading', @rebuildMarkers
    @subscriptions.add @asDisposable atom.config.observe 'editor.lineHeight', @rebuildMarkers
    @subscriptions.add @asDisposable atom.config.observe 'editor.fontSize', @rebuildMarkers

  setModel: (model) ->
    @unsubscribeFromModel()
    @model = model
    @subscribeToModel()

  setEditorView: (editorView) ->
    @unsubscribeFromEditor()
    @editorView = editorView
    {@editor} = @editorView
    @subscribeToEditor()

  subscribeToModel: ->
    return unless @model?
    @subscribe @model, 'updated', @markersUpdated

  unsubscribeFromModel: ->
    return unless @model?
    @unsubscribe @model, 'updated'

  subscribeToEditor: ->
    return unless @editor?
    @subscriptions.add @editor.onDidAddCursor @requestSelectionUpdate
    @subscriptions.add @editor.onDidRemoveCursor @requestSelectionUpdate
    @subscriptions.add @editor.onDidChangeCursorPosition @requestSelectionUpdate
    @subscriptions.add @editor.onDidAddSelection @requestSelectionUpdate
    @subscriptions.add @editor.onDidRemoveSelection @requestSelectionUpdate
    @subscriptions.add @editor.onDidChangeSelectionRange @requestSelectionUpdate

  requestSelectionUpdate: =>
    return if @updateRequested

    @updateRequested = true
    requestAnimationFrame =>
      @updateSelections()
      @updateRequested = false

  unsubscribeFromEditor: ->
    return unless @editor?
    @editorSubscriptions.dispose()

  updateSelections: =>
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
    @detach()

  getMarkerAt: (position) ->
    for id, view of @markerViews
      return view if view.marker.bufferMarker.containsPoint(position)

  removeMarkers: ->
    markerView.remove() for id, markerView of @markerViews
    @markerViews = {}

  markersUpdated: (@markers) =>
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
          markerView = new DotMarkerView({@editorView, marker, markersByRows})
          sortedMarkers.push markerView
        else
          markerView = new MarkerView({@editorView, marker})
        @append(markerView.element)
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

  rebuildMarkers: =>
    return unless @markers
    markersByRows = {}

    for marker in @markers
      @markerViews[marker.id].remove() if @markerViews[marker.id]?

      if atom.config.get('atom-color-highlight.markersAtEndOfLine')
        markerView = new DotMarkerView({@editorView, marker, markersByRows})
      else
        markerView = new MarkerView({@editorView, marker})

      @append(markerView.element)
      @markerViews[marker.id] = markerView

  destroyAllViews: ->
    @empty()
    @markerViews = {}

  asDisposable: (subscription) -> new Disposable -> subscription.off()
