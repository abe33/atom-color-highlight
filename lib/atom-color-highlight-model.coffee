_ = require 'underscore-plus'
{Emitter} = require 'emissary'

Color = require './color-model'

require './color-expressions'

module.exports =
class AtomColorHighlightModel
  Emitter.includeInto(this)

  @markerClass: 'color-highlight'
  @bufferRange: [[0,0], [Infinity,Infinity]]

  constructor: (@editor, @buffer) ->
    customProperties = @buffer.getMarkers().map (m) -> m.properties.color
    console.log customProperties
    console.log customProperties.length

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
      @editor.scanInBufferRange(
        Color.colorRegexp(),
        @constructor.bufferRange,
        block
      )

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
        colorObject = new Color(color)

        if marker = @findMarker(color, range)
          delete markersToRemoveById[marker.id]
        else
          marker = @createMarker(color, colorObject, range)

        updatedMarkers.push marker

      marker.destroy() for id, marker of markersToRemoveById

      @markers = updatedMarkers
      @emit 'updated', _.clone(@markers)
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
    markerAttributes =
      type: @constructor.markerClass
      color: color
      cssColor: colorObject.toCSS()
      invalidation: 'inside'
      persistent: false
    @editor.markBufferRange(range, markerAttributes)
