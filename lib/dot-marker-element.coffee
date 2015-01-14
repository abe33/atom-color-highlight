{CompositeDisposable} = require 'event-kit'
MarkerMixin = require './marker-mixin'

module.exports =
class DotMarkerElement extends HTMLElement
  MarkerMixin.includeInto(this)

  createdCallback: ->
    @subscriptions = new CompositeDisposable()

  init: ({@editorElement, @editor, @marker, @markersByRows}) ->
    @innerHTML = '<div class="selector"/>'

    @updateNeeded = @marker.isValid()
    @oldScreenRange = @getScreenRange()
    @buffer = @editor.getBuffer()
    @clearPosition = true

    @subscribeToMarker()
    @updateDisplay()

  updateDisplay: =>
    return unless @isUpdateNeeded()

    @updateNeeded = false
    range = @getScreenRange()
    return if range.isEmpty()

    @hide() if @isHidden()

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
    {top, left} = @editorElement.pixelPositionForScreenPosition(position)
    @style.top = top + 'px'
    @style.width = size + 'px'
    @style.height = size + 'px'
    @style.left = (left + spacing + @position * (size + spacing)) + 'px'
    @style.backgroundColor = color
    @style.color = colorText

  getSize: -> atom.config.get('atom-color-highlight.dotMarkersSize')
  getSpacing: -> atom.config.get('atom-color-highlight.dotMarkersSpacing')

module.exports = DotMarkerElement = document.registerElement 'dot-color-marker', prototype: DotMarkerElement.prototype
