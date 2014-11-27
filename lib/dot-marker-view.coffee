{View, $} = require 'atom'
{Subscriber} = require 'emissary'
MarkerMixin = require './marker-mixin'

module.exports =
class DotMarkerView
  Subscriber.includeInto(this)
  MarkerMixin.includeInto(this)

  constructor: ({@editorView, @marker, @markersByRows}) ->
    @editor = @editorView.editor
    @element = document.createElement('div')
    @element.innerHTML = '<div class="selector"/>'
    @element.className = 'dot-marker color-highlight'
    @updateNeeded = @marker.isValid()
    @oldScreenRange = @getScreenRange()
    @buffer = @editor.buffer
    @clearPosition = true

    @subscribeToMarker()
    @updateDisplay()

  updateDisplay: =>
    return unless @isUpdateNeeded()

    @updateNeeded = false
    range = @getScreenRange()
    return if range.isEmpty()

    @hide() if @hidden()

    size = @getSize()
    spacing = @getSpacing()
    @markersByRows[range.start.row] ?= 0

    if @clearPosition
      @position = @markersByRows[range.start.row]
      @clearPosition = false

    @markersByRows[range.start.row]++

    color = @getColor()
    colorText = @getColorTextColor()
    line = @editor.lineTextForScreenRow(range.start.row)
    lineLength = line.length
    position = row: range.start.row, column: lineLength
    {top, left} = @editorView.pixelPositionForScreenPosition(position)
    @element.style.top = top + 'px'
    @element.style.width = size + 'px'
    @element.style.height = size + 'px'
    @element.style.left = (left + spacing + @position * (size + spacing)) + 'px'
    @element.style.backgroundColor = color
    @element.style.color = colorText

  getSize: -> atom.config.get('atom-color-highlight.dotMarkersSize')
  getSpacing: -> atom.config.get('atom-color-highlight.dotMarkersSpacing')
