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
    setImmediate =>
      color = @getColor()
      colorText = @getColorText()


      {start, end} = @getScreenRange()
      {top, left} = @editorView.pixelPositionForScreenPosition(start)
      width = @editorView.pixelPositionForScreenPosition(end).left - left

      @text colorText
      @css
        top: top + 'px'
        left: left + 'px'
        background: color
        borderColor: color
        color: @getColorTextColor()

  getColor: -> @marker.bufferMarker.properties.cssColor
  getColorText: -> @marker.bufferMarker.properties.color
  getColorTextColor: -> @marker.bufferMarker.properties.textColor
  getScreenRange: -> @marker.getScreenRange()
