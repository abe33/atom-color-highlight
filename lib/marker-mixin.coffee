Mixin = require 'mixto'
{CompositeDisposable} = require 'event-kit'

module.exports =
class MarkerMixin extends Mixin
  addClass: (cls) -> @classList.add(cls)
  removeClass: (cls) -> @classList.remove(cls)

  remove: ->
    @subscriptions.dispose()
    @marker = null
    @editor = null
    @editor = null

    @parentNode?.removeChild(this)

  show: ->
    @style.display = "" unless @isHidden()

  hide: ->
    @style.display = "none"

  isVisible: ->
    oldScreenRange = @oldScreenRange
    newScreenRange = @getScreenRange()

    @oldScreenRange = newScreenRange
    @intersectsRenderedScreenRows(oldScreenRange) or @intersectsRenderedScreenRows(newScreenRange)

  subscribeToMarker: ->
    @subscriptions ?= new CompositeDisposable
    @subscriptions.add @marker.onDidChange (e) => @onMarkerChanged(e)
    @subscriptions.add @marker.onDidDestroy (e) => @remove()

    @subscriptions.add @editor.onDidChangeScrollTop (e) => @updateDisplay()

  onMarkerChanged: ({isValid}) ->
    @updateNeeded = isValid
    @updateDisplay()
    @updateVisibility()

  updateVisibility: ->
    if @isVisible() then @show() else @hide()

  isUpdateNeeded: ->
    return false unless @updateNeeded
    @isVisible()

  intersectsRenderedScreenRows: (range) ->
    range.intersectsRowRange(@editorElement.getFirstVisibleScreenRow(), @editorElement.getLastVisibleScreenRow())

  isHidden: ->
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

  getColor: -> @marker?.bufferMarker.properties.cssColor
  getColorText: -> @marker?.bufferMarker.properties.color
  getColorTextColor: -> @marker?.bufferMarker.properties.textColor
  getScreenRange: -> @marker?.getScreenRange()
  getBufferRange: -> @marker?.getBufferRange()
