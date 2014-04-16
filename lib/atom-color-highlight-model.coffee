_ = require 'underscore-plus'
{Emitter} = require 'emissary'
{OnigRegExp} = require 'oniguruma'
Color = require './color-model'

require './color-expressions'

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
    @buffer.off 'contents-modified', @update
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
    @onigScanInBuffer(Color.colorRegExp(), block) if @buffer?

  onigScanInBuffer: (regexp, iterator) ->
    ore = new OnigRegExp(regexp)
    text = @buffer.getText()
    searchOffset = 0
    # ore.search text, searchOffset, (err, matches) ->
    while (matches = ore.searchSync(text, searchOffset))?
      [match] = matches
      matchText = match.match
      searchOffset = match.end

      startPosition = @buffer.positionForCharacterIndex(match.start)
      endPosition = @buffer.positionForCharacterIndex(match.end)
      range = new @buffer.constructor.Range(startPosition, endPosition)
      iterator({ match, matchText, range })


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
    [h,s,v] = colorObject.hsv
    textColor = if v > 50
      'black'
    else
      'white'

    markerAttributes =
      type: @constructor.markerClass
      color: color
      cssColor: colorObject.toCSS()
      textColor: textColor
      invalidation: 'inside'
      persistent: false

    @editor.markBufferRange(range, markerAttributes)
