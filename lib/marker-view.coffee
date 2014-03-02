{View, $} = require 'atom'
{Subscriber} = require 'emissary'

module.exports =
class MarkerView extends View
  Subscriber.includeInto(this)

  @content: ->
    @span class: 'color-highlight'

  constructor: ({@editorView, @marker}) ->
    super

    @subscribeToMarker()

    @updateDisplay()

  subscribeToMarker: ->
    @subscribe @marker, 'changed', @updateDisplay
    @subscribe @marker, 'destroyed', @unsubscribeFromMarker

  unsubscribeFromMarker: =>
    @unsubscribe @marker, 'changed', @updateDisplay
    @unsubscribe @marker, 'destroyed', @unsubscribeFromMarker

  updateDisplay: =>
    color = @getColor()

    {start, end} = @getScreenRange()
    {top, left} = @editorView.pixelPositionForScreenPosition(start)
    width = @editorView.pixelPositionForScreenPosition(end).left - left

    @css
      top: top + 'px'
      left: left + 'px'
      background: color
      color: color
      width: width + 'px'

  getColor: -> @marker.bufferMarker.properties.color
  getScreenRange: -> @marker.getScreenRange()
