{View, $} = require 'atom'
{Subscriber} = require 'emissary'

module.exports =
class MarkerView
  Subscriber.includeInto(this)

  constructor: ({@editorView, @marker}) ->
    @regions = []
    @editor = @editorView.editor
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
    @editor = null
    @element.remove()

  show: ->
    @element.style.display = "" unless @hiddenDueToComment()

  hide: ->
    @element.style.display = "none"

  addClass: (cls) -> @element.classList.add(cls)
  removeClass: (cls) -> @element.classList.remove(cls)

  subscribeToMarker: ->
    @subscribe @marker, 'changed', @onMarkerChanged
    @subscribe @marker, 'destroyed', @remove
    @subscribe @editorView, 'editor:display-updated', @updateDisplay

  onMarkerChanged: ({isValid}) =>
    @updateNeeded = isValid
    if isValid then @show() else @hide()

  isUpdateNeeded: ->
    return false unless @updateNeeded and @editor is @editorView.editor

    oldScreenRange = @oldScreenRange
    newScreenRange = @getScreenRange()
    @oldScreenRange = newScreenRange
    @intersectsRenderedScreenRows(oldScreenRange) or @intersectsRenderedScreenRows(newScreenRange)

  intersectsRenderedScreenRows: (range) ->
    range.intersectsRowRange(@editorView.firstRenderedScreenRow, @editorView.lastRenderedScreenRow)

  hiddenDueToComment: ->
    bufferRange = @getBufferRange()
    scope = @editor.displayBuffer.scopesForBufferPosition(bufferRange.start).join(';')

    atom.config.get('atom-color-highlight.hideMarkersInComments') and scope.match(/\bcomment\b/)

  updateDisplay: =>
    return unless @isUpdateNeeded()

    @updateNeeded = false
    @clearRegions()
    range = @getScreenRange()
    return if range.isEmpty()

    @hide() if @hiddenDueToComment()

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
    bufferRange = @editor.bufferRangeForScreenRange({start, end})
    text = @editor.getTextInRange(bufferRange)

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
  getBufferRange: -> @marker.getBufferRange()
