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
    @remove()

  updateDisplay: =>
    setImmediate =>
      color = @getColor()
      colorText = @getColorText()

      {start, end} = @getScreenRange()
      if end.row is start.row
        {top, left} = @editorView.pixelPositionForScreenPosition(start)
      else
        {top, left} = @editorView.pixelPositionForScreenPosition([end.row, 0])

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
