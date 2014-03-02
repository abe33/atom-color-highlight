_ = require 'underscore-plus'
{Emitter} = require 'emissary'

module.exports =
class AtomColorHighlightModel
  Emitter.includeInto(this)

  @markerClass: 'color-highlight'
  @bufferRange: [[0,0], [Infinity,Infinity]]

  constructor: (@editor, @buffer) ->

  update: =>
    @updateMarkers()

  subscribeToBuffer: ->
    @buffer.on 'contents-modified', @update

  unsubscribeFromBuffer: ->
    @buffer.off 'contents-modified', @updateModel
    @buffer = null

  init: ->
    if @buffer?
      @subscribeToBuffer()
      @destroyAllMarkers()
      @update()

  dispose: ->
    if @buffer?
      @unsubscribeFromBuffer()

  eachColor: (block) ->
    if @buffer?
      @editor.scanInBufferRange @getColorRegexp(), @constructor.bufferRange, block

  getColorRegexp: ->
    int = '\\d+'
    float = '\\d+(\\.\\d+)?'
    percent = "#{float}%"
    intOrPercent = "(#{int}|#{percent})"
    comma = '\\s*,\\s*'

    ///
      (\#[\da-fA-F]{6}(?!\d))
      |
      (\#[\da-fA-F]{3}(?!\d))
      |
      (rgb\(\s*
        #{intOrPercent}
        #{comma}
        #{intOrPercent}
        #{comma}
        #{intOrPercent}
      \))
      |
      (rgba\(\s*
        #{intOrPercent}
        #{comma}
        #{intOrPercent}
        #{comma}
        #{intOrPercent}
        #{comma}
        #{float}
      \))
      |
      (hsl\(\s*
        #{int}
        #{comma}
        #{percent}
        #{comma}
        #{percent}
      \))
      |
      (hsla\(\s*
        #{int}
        #{comma}
        #{percent}
        #{comma}
        #{percent}
        #{comma}
        #{float}
      \))
    ///g

  updateMarkers: ->
    if not @buffer?
      @destroyAllMarkers()
      return

    updatedMarkers = []
    markersToRemoveById = {}

    markersToRemoveById[marker.id] = marker for marker in @markers

    try
      @eachColor (res) =>
        {range, matchText: color} = res

        if marker = @findMarker(color, range)
          delete markersToRemoveById[marker.id]
        else
          marker = @createMarker(color, range)

        updatedMarkers.push marker

      marker.destroy() for id, marker of markersToRemoveById

      @markers = updatedMarkers
      @emit 'updated', _.clone(@markers)
    catch e
      @destroyAllMarkers()
      throw e

  findMarker: (color, range) ->
    attributes =
      class: @constructor.markerClass
      color: color
      startPosition: range.start
      endPosition: range.end

    _.find @editor.findMarkers(attributes), (marker) -> marker.isValid()

  destroyAllMarkers: ->
    marker.destroy() for marker in @markers ? []
    @markers = []
    @emit 'updated', _.clone(@markers)

  createMarker: (color, range) ->
    markerAttributes =
      class: @constructor.markerClass
      color: color
      invalidation: 'inside'
      replicate: false
      persist: false
      isCurrent: false
    @editor.markBufferRange(range, markerAttributes)
