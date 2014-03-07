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
    @cursors = []
    @markerViews = {}
    @subscribe @model, 'updated', @markersUpdated
    @subscribe @editor, 'cursor-added', @updateCursors
    @updateCursors()

  updateCursors: =>
    cursors = @editor.getCursors()
    cursorsToBeRemoved = @cursors.concat()

    for cursor in cursors
      if cursor in @cursors
        _.remove cursorsToBeRemoved, cursor
      else
        @subscribeToCursor cursor
        marker = @getMarkerAt(cursor.getBufferPosition())
        marker?.hide()

    for cursor in cursorsToBeRemoved
      @unsubscribeFromCursor cursor
      marker = @getMarkerAt(cursor.getBufferPosition())
      marker?.show()
    @cursors = cursors

  subscribeToCursor: (cursor) ->
    @subscribe cursor, 'moved', @cursorMoved
    @subscribe cursor, 'destroyed', @updateCursors

  unsubscribeFromCursor: (cursor) ->
    @unsubscribe cursor, 'moved', @cursorMoved
    @unsubscribe cursor, 'destroyed'

  # Tear down any state and detach
  destroy: ->
    @unsubscribe @editor, 'cursor-added'
    @unsubscribeFromCursor(cursor) for cursor in @editor.getCursors()
    @destroyAllViews()
    @detach()

  getMarkerAt: (position) ->
    for id, view of @markerViews
      return view if view.marker.bufferMarker.containsPoint(position)

  cursorMoved: ({oldBufferPosition, newBufferPosition}) =>
    oldMarker = @getMarkerAt oldBufferPosition
    newMarker = @getMarkerAt newBufferPosition

    oldMarker?.show()
    newMarker?.hide()

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
