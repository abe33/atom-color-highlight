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
    @markerViews = {}
    @subscribe @model, 'updated', @markersUpdated

  # Tear down any state and detach
  destroy: ->
    @destroyAllViews()
    @detach()

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
