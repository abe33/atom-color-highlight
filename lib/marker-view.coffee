{View, $} = require 'atom'
{Subscriber} = require 'emissary'

module.exports =
class MarkerView
  Subscriber.includeInto(this)

  constructor: ({@editorView, @marker}) ->
    @regions = []
    @editSession = @editorView.editor
    @element = document.createElement('div')
    @element.className = 'marker color-highlight'
    @updateNeeded = @marker.isValid()
    @oldScreenRange = @getScreenRange()

    @subscribeToMarker()
    @updateDisplay()

  remove: =>
    @unsubscribe()
    @marker = null
    @editorView = null
    @editSession = null
    @element.remove()

  show: ->
    @element.style.display = ""

  hide: ->
    @element.style.display = "none"

  subscribeToMarker: ->
    @subscribe @marker, 'changed', @onMarkerChanged
    @subscribe @marker, 'destroyed', @remove
    @subscribe @editorView, 'editor:display-updated', @updateDisplay

  onMarkerChanged: ({isValid}) =>
    @updateNeeded = isValid
    if isValid then @show() else @hide()

  isUpdateNeeded: ->
    return false unless @updateNeeded and @editSession is @editorView.editor

    oldScreenRange = @oldScreenRange
    newScreenRange = @getScreenRange()
    @oldScreenRange = newScreenRange
    @intersectsRenderedScreenRows(oldScreenRange) or @intersectsRenderedScreenRows(newScreenRange)

  intersectsRenderedScreenRows: (range) ->
    range.intersectsRowRange(@editorView.firstRenderedScreenRow, @editorView.lastRenderedScreenRow)

  updateDisplay: =>
    return unless @isUpdateNeeded()

    @updateNeeded = false
    @clearRegions()
    range = @getScreenRange()
    return if range.isEmpty()

    rowSpan = range.end.row - range.start.row

    if rowSpan == 0
      @appendRegion(1, range.start, range.end)
    else
      @appendRegion(1, range.start, {row: range.start.row, column: Infinity})
      if rowSpan > 1
        @appendRegion(rowSpan - 1, { row: range.start.row + 1, column: 0}, {row: range.start.row + 1, column: Infinity})
      @appendRegion(1, { row: range.end.row, column: 0 }, range.end)

  appendRegion: (rows, start, end) ->
    { lineHeight, charWidth } = @editorView
    color = @getColor()
    colorText = @getColorTextColor()
    bufferRange = @editSession.bufferRangeForScreenRange({start, end})
    text = @editSession.getTextInRange(bufferRange)

    css = @editorView.pixelPositionForScreenPosition(start)
    css.height = lineHeight * rows
    if end
      css.width = @editorView.pixelPositionForScreenPosition(end).left - css.left
    else
      css.right = 0

    region = document.createElement('div')
    region.className = 'region'
    region.textContent = text
    for name, value of css
      region.style[name] = value + 'px'

    region.style.backgroundColor = color
    region.style.color = colorText

    @element.appendChild(region)
    @regions.push(region)

  clearRegions: ->
    region.remove() for region in @regions
    @regions = []

  getColor: -> @marker.bufferMarker.properties.cssColor
  getColorText: -> @marker.bufferMarker.properties.color
  getColorTextColor: -> @marker.bufferMarker.properties.textColor
  getScreenRange: -> @marker.getScreenRange()
