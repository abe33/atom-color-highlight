Mixin = require 'mixto'
{CompositeDisposable} = require 'event-kit'

module.exports =
class MarkerMixin extends Mixin
  addClass: (cls) -> @element.classList.add(cls)
  removeClass: (cls) -> @element.classList.remove(cls)

  remove: ->
    @unsubscribe()
    @subscriptions.dispose()
    @marker = null
    @editorView = null
    @editor = null
    @element.remove()

  show: ->
    @element.style.display = "" unless @hidden()

  hide: ->
    @element.style.display = "none"

  subscribeToMarker: ->
    @subscriptions ?= new CompositeDisposable
    @subscriptions.add @marker.onDidChange (e) => @onMarkerChanged(e)
    @subscriptions.add @marker.onDidDestroy (e) => @remove(e)
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

  getScope: (bufferRange) ->
    if @editor.displayBuffer.scopesForBufferPosition?
      @editor.displayBuffer.scopesForBufferPosition(bufferRange.start).join(';')
    else
      descriptor = @editor.displayBuffer.scopeDescriptorForBufferPosition(bufferRange.start)
      if descriptor.join?
        descriptor.join(';')
      else
        descriptor.scopes.join(';')

  hiddenDueToComment: ->
    bufferRange = @getBufferRange()
    scope = @getScope(bufferRange)

    atom.config.get('atom-color-highlight.hideMarkersInComments') and scope.match(/comment/)?

  hiddenDueToString: ->
    bufferRange = @getBufferRange()
    scope = @getScope(bufferRange)
    atom.config.get('atom-color-highlight.hideMarkersInStrings') and scope.match(/string/)?

  getColor: -> @marker.bufferMarker.properties.cssColor
  getColorText: -> @marker.bufferMarker.properties.color
  getColorTextColor: -> @marker.bufferMarker.properties.textColor
  getScreenRange: -> @marker.getScreenRange()
  getBufferRange: -> @marker.getBufferRange()
