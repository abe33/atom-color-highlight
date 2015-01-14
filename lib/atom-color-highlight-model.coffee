_ = require 'underscore-plus'
{CompositeDisposable, Emitter} = require 'event-kit'

module.exports =
class AtomColorHighlightModel
  @idCounter: 0

  @markerClass: 'color-highlight'
  @bufferRange: [[0,0], [Infinity,Infinity]]

  constructor: (@editor) ->
    @buffer = @editor.getBuffer()
    @id = AtomColorHighlightModel.idCounter++
    @dirty = false
    @emitter = new Emitter
    @subscriptions = new CompositeDisposable

  onDidUpdateMarkers: (callback) ->
    @emitter.on 'did-update-markers', callback

  onDidDestroy: (callback) ->
    @emitter.on 'did-destroy', callback

  update: =>
    return if @frameRequested

    @frameRequested = true
    requestAnimationFrame =>
      @frameRequested = false
      @updateMarkers()

  subscribeToBuffer: ->
    @subscriptions.add @editor.onDidChange => @dirty = true
    @subscriptions.add @editor.onDidStopChanging => @update()
    @subscriptions.add @editor.displayBuffer.onDidTokenize => @update()
    @subscriptions.add @editor.onDidDestroy => @destroy()

  unsubscribeFromBuffer: ->
    @subscriptions.dispose()
    @buffer = null

  init: ->
    @subscribeToBuffer()
    @destroyAllMarkers()
    @update()

  destroy: ->
    @destroyed = true
    @emitter.emit('did-destroy')
    @unsubscribeFromBuffer() if @buffer?

  isDestroyed: -> @destroyed

  eachColor: (block) ->
    return @constructor.Color.scanBufferForColors(@buffer, block) if @buffer?

  updateMarkers: ->
    return @destroyAllMarkers() unless @buffer?
    return if @updating

    @updating = true
    updatedMarkers = []
    markersToRemoveById = {}

    markersToRemoveById[marker.id] = marker for marker in @markers

    try
      promise = @eachColor()

      promise.then (results) =>
        @updating = false
        results = [] unless results?

        for res in results
          continue unless res?

          {bufferRange: range, match, color} = res

          continue if color.isInvalid

          if marker = @findMarker(match, range)
            if marker.bufferMarker.properties.cssColor isnt color.toCSS()
              marker = @createMarker(match, color, range)
            else
              delete markersToRemoveById[marker.id]
          else
            marker = @createMarker(match, color, range)

          updatedMarkers.push marker

        marker.destroy() for id, marker of markersToRemoveById

        @markers = updatedMarkers
        @emitter.emit 'did-update-markers', _.clone(@markers)
        @dirty = false
      .fail (e) ->
        @dirty = false
        console.log e

    catch e
      @destroyAllMarkers()
      throw e

  findMarker: (color, range) ->
    attributes =
      type: @constructor.markerClass
      color: color
      startPosition: range.start
      endPosition: range.end

    _.find @editor.findMarkers(attributes), (marker) -> marker.isValid()

  destroyAllMarkers: ->
    marker.destroy() for marker in @markers ? []
    @markers = []
    @emitter.emit 'did-update-markers', _.clone(@markers)

  createMarker: (color, colorObject, range) ->
    l = colorObject.luma()

    textColor = if l > 0.43
      'black'
    else
      'white'

    markerAttributes =
      type: @constructor.markerClass
      color: color
      cssColor: colorObject.toCSS()
      textColor: textColor
      invalidate: 'touch'
      persistent: false

    @editor.markBufferRange(range, markerAttributes)
