_ = require 'underscore-plus'
{View, $} = require 'atom'
{Subscriber} = require 'emissary'

MarkerView = require './marker-view'

module.exports =
class AtomColorHighlightView extends View
  Subscriber.includeInto(this)

  @content: ->
    @div class: 'atom-color-highlight'

  constructor: (model, editorView) ->
    super
    @selections = []
    @markerViews = {}

    @setEditorView(editorView)
    @setModel(model)

    @updateSelections()

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
      for selection in @selections
        range = selection.getScreenRange()
        viewRange = view.getScreenRange()
        if viewRange.intersectsWith(range)
          view.hide()
          delete viewsToBeDisplayed[id]

    view.show() for id,view of viewsToBeDisplayed

  removeMarkers: ->
    markerView.remove() for id, markerView of @markerViews
    @markerViews = {}

  markersUpdated: (markers) =>
    markerViewsToRemoveById = _.clone(@markerViews)

    for marker in markers
      if @markerViews[marker.id]?
        delete markerViewsToRemoveById[marker.id]
      else
        markerView = new MarkerView({@editorView, marker})
        @append(markerView.element)
        @markerViews[marker.id] = markerView

    for id, markerView of markerViewsToRemoveById
      delete @markerViews[id]
      markerView.remove()

  destroyAllViews: ->
    @empty()
    @markerViews = {}
