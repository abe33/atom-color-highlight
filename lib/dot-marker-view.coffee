{View, $} = require 'atom'
{Subscriber} = require 'emissary'

module.exports =
class DotMarkerView
  Subscriber.includeInto(this)

  constructor: ({@editorView, @marker, @markersByRows}) ->
    @editor = @editorView.editor
    @element = document.createElement('div')
    @element.innerHTML = '<div class="selector"/>'
    @element.className = 'dot-marker color-highlight'
    @updateNeeded = @marker.isValid()
    @oldScreenRange = @getScreenRange()
    @buffer = @editor.buffer

    @subscribeToMarker()
    @updateDisplay()

  remove: =>
    @unsubscribe()
    @marker = null
    @editorView = null
    @editor = null
    @element.remove()

  addClass: (cls) -> @element.classList.add(cls)
  removeClass: (cls) -> @element.classList.remove(cls)

  show: ->
    @element.style.display = "" unless @hiddenDueToComment()

  hide: ->
    @element.style.display = "none"

  hiddenDueToComment: ->
    bufferRange = @getBufferRange()
    scope = @editor.displayBuffer.scopesForBufferPosition(bufferRange.start).join(';')

    atom.config.get('atom-color-highlight.hideMarkersInComments') and scope.match(/\bcomment\b/)

  subscribeToMarker: ->
    @subscribe @marker, 'changed', @onMarkerChanged
    @subscribe @marker, 'destroyed', @remove
    @subscribe @editorView, 'editor:display-updated', @updateDisplay

  onMarkerChanged: ({isValid}) =>
    @updateNeeded = isValid
    if isValid then @show() else @hide()

  isUpdateNeeded: ->
    return false unless @updateNeeded and @editor is @editorView?.editor

    oldScreenRange = @oldScreenRange
    newScreenRange = @getScreenRange()
    @oldScreenRange = newScreenRange
    @intersectsRenderedScreenRows(oldScreenRange) or @intersectsRenderedScreenRows(newScreenRange)

  intersectsRenderedScreenRows: (range) ->
    range.intersectsRowRange(@editorView.firstRenderedScreenRow, @editorView.lastRenderedScreenRow)

  updateDisplay: =>
    return unless @isUpdateNeeded()

    @updateNeeded = false
    range = @getScreenRange()
    return if range.isEmpty()

    @hide() if @hiddenDueToComment()

    size = atom.config.get('atom-color-highlight.dotMarkersSize')
    spacing = atom.config.get('atom-color-highlight.dotMarkersSpacing')
    @markersByRows[range.start.row] ?= 0
    @position ?= @markersByRows[range.start.row]
    @markersByRows[range.start.row]++

    color = @getColor()
    colorText = @getColorTextColor()
    lineLength = @editor.displayBuffer.getLines()[range.start.row].text.length
    position = row: range.start.row, column: lineLength
    {top, left} = @editorView.pixelPositionForScreenPosition(position)
    @element.style.top = top + 'px'
    @element.style.width = size + 'px'
    @element.style.height = size + 'px'
    @element.style.left = (left + spacing + @position * (size + spacing)) + 'px'
    @element.style.backgroundColor = color
    @element.style.color = colorText

  getColor: -> @marker.bufferMarker.properties.cssColor
  getColorText: -> @marker.bufferMarker.properties.color
  getColorTextColor: -> @marker.bufferMarker.properties.textColor
  getScreenRange: -> @marker.getScreenRange()
