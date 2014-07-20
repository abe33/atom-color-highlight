_ = require 'underscore-plus'
{View, $} = require 'atom'
{Subscriber} = require 'emissary'

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

    @observeConfig()
    @setEditorView(editorView)
    @setModel(model)

    @updateSelections()

  observeConfig: ->
    atom.config.observe 'atom-color-highlight.hideMarkersInComments', @rebuildMarkers
    atom.config.observe 'atom-color-highlight.hideMarkersInStrings', @rebuildMarkers
    atom.config.observe 'atom-color-highlight.markersAtEndOfLine', @rebuildMarkers
    atom.config.observe 'atom-color-highlight.dotMarkersSize', @rebuildMarkers
    atom.config.observe 'atom-color-highlight.dotMarkersSpading', @rebuildMarkers

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
    @subscribe @editor, 'selection-added', => setImmediate => @updateSelections

  unsubscribeFromEditor: ->
    return unless @editor?
    @unsubscribe @editor, 'selection-added'

  updateSelections: =>
    selections = @editor.getSelections()
    selectionsToBeRemoved = @selections.concat()

    for selection in selections
      if selection in @selections
        _.remove selectionsToBeRemoved, selection
      else
        @subscribeToSelection selection

    for selection in selectionsToBeRemoved
      @unsubscribeFromSelection selection
    @selections = selections
    @selectionChanged()

  subscribeToSelection: (selection) ->
    @subscribe selection, 'screen-range-changed', @selectionChanged
    @subscribe selection, 'destroyed', @updateSelections

  unsubscribeFromSelection: (selection) ->
    @unsubscribe selection, 'screen-range-changed', @selectionChanged
    @unsubscribe selection, 'destroyed'

  # Tear down any state and detach
  destroy: ->
    @unsubscribe @editor, 'selection-added'
    for selection in @editor.getSelections()
      @unsubscribeFromSelection(selection)
    @destroyAllViews()
    @detach()

  getMarkerAt: (position) ->
    for id, view of @markerViews
      return view if view.marker.bufferMarker.containsPoint(position)

  selectionChanged: =>
    viewsToBeDisplayed = _.clone(@markerViews)

    for id,view of @markerViews
      view.removeClass('selected')

      for selection in @selections
        range = selection.getScreenRange()
        viewRange = view.getScreenRange()
        if viewRange.intersectsWith(range)
          view.addClass('selected')
          delete viewsToBeDisplayed[id]

    view.show() for id,view of viewsToBeDisplayed

  removeMarkers: ->
    markerView.remove() for id, markerView of @markerViews
    @markerViews = {}

  markersUpdated: (@markers) =>
    markerViewsToRemoveById = _.clone(@markerViews)
    markersByRows = {}

    for marker in @markers
      if @markerViews[marker.id]?
        delete markerViewsToRemoveById[marker.id]
      else
        if atom.config.get('atom-color-highlight.markersAtEndOfLine')
          markerView = new DotMarkerView({@editorView, marker, markersByRows})
        else
          markerView = new MarkerView({@editorView, marker})
        @append(markerView.element)
        @markerViews[marker.id] = markerView

    for id, markerView of markerViewsToRemoveById
      delete @markerViews[id]
      markerView.remove()

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
