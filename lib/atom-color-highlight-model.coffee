_ = require 'underscore-plus'
{Emitter, Subscriber} = require 'emissary'
{OnigRegExp} = require 'oniguruma'
Color = require 'pigments'

module.exports =
class AtomColorHighlightModel
  Emitter.includeInto(this)
  Subscriber.includeInto(this)

  @Color: Color

  @markerClass: 'color-highlight'
  @bufferRange: [[0,0], [Infinity,Infinity]]

  constructor: (@editor, @buffer) ->
    finder = atom.packages.getLoadedPackage('project-palette-finder')
    if finder?
      module = require(finder.path)
      Color = module.constructor.Color
      @subscribe module, 'palette:ready', @update

    @constructor.Color = Color

  update: =>
    return if @frameRequested

    @frameRequested = true
    webkitRequestAnimationFrame =>
      @frameRequested = false
      @updateMarkers()

  subscribeToBuffer: ->
    @subscribe @buffer, 'contents-modified', @update

  unsubscribeFromBuffer: ->
    @unsubscribe @buffer, 'contents-modified', @update
    @buffer = null

  init: ->
    if @buffer?
      @subscribeToBuffer()
      @destroyAllMarkers()
      @update()

  dispose: ->
    @unsubscribe()
    @unsubscribeFromBuffer() if @buffer?

  eachColor: (block) ->
    return Color.scanBufferForColors(@buffer, block) if @buffer?

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
        @emit 'updated', _.clone(@markers)
      .fail (e) ->
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
    @emit 'updated', _.clone(@markers)

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
