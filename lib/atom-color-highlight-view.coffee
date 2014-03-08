_ = require 'underscore-plus'
{View, $} = require 'atom'
{Subscriber} = require 'emissary'

MarkerView = require './marker-view'

module.exports =
class AtomColorHighlightView extends View
  Subscriber.includeInto(this)

  @content: ->
    @div class: 'atom-color-highlight'

  constructor: (@model, @editorView) ->
    super
    {@editor} = @editorView
    @selections = []
    @markerViews = {}
    @subscribe @model, 'updated', @markersUpdated
    @subscribe @editor, 'selection-added', @updateSelections
    @updateSelections()

  updateSelections: =>
    selections = @editor.getSelections()
    selectionsToBeRemoved = @selections.concat()

    for selection in selections
      if selection in @selections
        _.remove selectionsToBeRemoved, selection
      else
        @subscribeToSelection selection
        # marker = @getMarkerAt(selection.getBufferPosition())
        # marker?.hide()

    for selection in selectionsToBeRemoved
      @unsubscribeFromSelection selection
      # marker = @getMarkerAt(selection.getBufferPosition())
      # marker?.show()
    @selections = selections

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
    range = @editor.getSelectedScreenRange()
    for id,view of @markerViews
      viewRange = view.getScreenRange()
      if viewRange.intersectsWith(range)
        view.hide()
      else
        view.show()

    # oldMarker = @getMarkerAt oldBufferPosition
    # newMarker = @getMarkerAt newBufferPosition
    #
    # oldMarker?.show()
    # newMarker?.hide()

  markersUpdated: (markers) =>
    markerViewsToRemoveById = _.clone(@markerViews)

    for marker in markers
      if @markerViews[marker.id]?
        delete markerViewsToRemoveById[marker.id]
      else
        markerView = new MarkerView({@editorView, marker})
        @append(markerView)
        @markerViews[marker.id] = markerView

    for id, markerView of markerViewsToRemoveById
      delete @markerViews[id]
      markerView.remove()

    @editorView.requestDisplayUpdate()

  destroyAllViews: ->
    @empty()
    @markerViews = {}
