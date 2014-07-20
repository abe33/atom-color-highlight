Mixin = require 'mixto'

module.exports =
class MarkerMixin extends Mixin
  addClass: (cls) -> @element.classList.add(cls)
  removeClass: (cls) -> @element.classList.remove(cls)

  remove: ->
    @unsubscribe()
    @marker = null
    @editorView = null
    @editor = null
    @element.remove()

  show: ->
    @element.style.display = "" unless @hidden()

  hide: ->
    @element.style.display = "none"

  subscribeToMarker: ->
    @subscribe @marker, 'changed', (e) => @onMarkerChanged(e)
    @subscribe @marker, 'destroyed', (e) => @remove(e)
    @subscribe @editorView, 'editor:display-updated', (e) => @updateDisplay(e)

  onMarkerChanged: ({isValid}) ->
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

  hidden: ->
    @hiddenDueToComment() or @hiddenDueToString()

  hiddenDueToComment: ->
    bufferRange = @getBufferRange()
    scope = @editor.displayBuffer.scopesForBufferPosition(bufferRange.start).join(';')

    atom.config.get('atom-color-highlight.hideMarkersInComments') and scope.match(/comment/)?

  hiddenDueToString: ->
    bufferRange = @getBufferRange()
    scope = @editor.displayBuffer.scopesForBufferPosition(bufferRange.start).join(';')
    atom.config.get('atom-color-highlight.hideMarkersInStrings') and scope.match(/string/)?

  getColor: -> @marker.bufferMarker.properties.cssColor
  getColorText: -> @marker.bufferMarker.properties.color
  getColorTextColor: -> @marker.bufferMarker.properties.textColor
  getScreenRange: -> @marker.getScreenRange()
  getBufferRange: -> @marker.getBufferRange()
