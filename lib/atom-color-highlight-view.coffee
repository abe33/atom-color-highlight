{View, $} = require 'atom'
{Subscriber} = require 'emissary'


module.exports =
class AtomColorHighlightView extends View
  Subscriber.includeInto(this)

  @content: ->
    @div class: 'atom-color-highlight'

  constructor: (@model, @editorView) ->
    super
    @markers = []
    @subscribe @model, 'updated', (markers) =>
      @removeMarkers()
      @renderMarkers(markers)

  # Tear down any state and detach
  destroy: ->
    @detach()

  renderMarkers: (markers) ->
    markers.forEach (marker) =>
      color = marker.bufferMarker.properties.color

      m = $("<span>#{color}</span>")
      m.addClass marker.bufferMarker.properties.class

      {start, end} = marker.getScreenRange()
      {top, left} = @editorView.pixelPositionForScreenPosition(start)
      width = @editorView.pixelPositionForScreenPosition(end).left - left

      m.css
        top: top + 'px'
        left: left + 'px'
        background: color
        color: color
        width: width + 'px'

      @markers.push m
      @append m

  removeMarkers: ->
    @markers.forEach (marker) -> marker.remove()
