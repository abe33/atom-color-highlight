{CompositeDisposable} = require 'event-kit'
MarkerMixin = require './marker-mixin'

module.exports =
class MarkerElement extends HTMLElement
  MarkerMixin.includeInto(this)

  createdCallback: ->
    @regions = []

  init: ({@editorElement, @editor, @marker}) ->
    @updateNeeded = @marker.isValid()
    @oldScreenRange = @getScreenRange()

    @subscribeToMarker()
    @updateDisplay()

  updateDisplay: =>
    return unless @isUpdateNeeded()

    @updateNeeded = false
    @clearRegions()
    range = @getScreenRange()
    return if range.isEmpty()

    @hide() if @isHidden()

    rowSpan = range.end.row - range.start.row

    if rowSpan == 0
      @appendRegion(1, range.start, range.end)
    else
      @appendRegion(1, range.start, {row: range.start.row, column: Infinity})
      if rowSpan > 1
        @appendRegion(rowSpan - 1, { row: range.start.row + 1, column: 0}, {row: range.start.row + 1, column: Infinity})
      @appendRegion(1, { row: range.end.row, column: 0 }, range.end)

  appendRegion: (rows, start, end) ->
    { lineHeight, charWidth } = @editorElement
    color = @getColor()
    colorText = @getColorTextColor()
    bufferRange = @editor.bufferRangeForScreenRange({start, end})
    text = @editor.getTextInRange(bufferRange)

    css = @editorElement.pixelPositionForScreenPosition(start)
    css.height = lineHeight * rows
    if end
      css.width = @editorElement.pixelPositionForScreenPosition(end).left - css.left
    else
      css.right = 0

    region = document.createElement('div')
    region.className = 'region'
    region.textContent = text
    for name, value of css
      region.style[name] = value + 'px'

    region.style.backgroundColor = color
    region.style.color = colorText

    @appendChild(region)
    @regions.push(region)

  clearRegions: ->
    region.remove() for region in @regions
    @regions = []

module.exports = MarkerElement = document.registerElement 'color-marker', prototype: MarkerElement.prototype
