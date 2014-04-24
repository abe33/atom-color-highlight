_ = require 'underscore-plus'
{Emitter} = require 'emissary'
{OnigRegExp} = require 'oniguruma'
Color = require 'pigments'

module.exports =
class AtomColorHighlightModel
  Emitter.includeInto(this)

  @markerClass: 'color-highlight'
  @bufferRange: [[0,0], [Infinity,Infinity]]

  constructor: (@editor, @buffer) ->
    finder = atom.packages.getLoadedPackage('project-palette-finder')
    Color = require(finder.path).constructor.Color if finder?

  update: =>
    return if @frameRequested

    @frameRequested = true
    webkitRequestAnimationFrame =>
      console.log 'update start'
      @frameRequested = false
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
    return Color.scanBufferForColors(@buffer, block) if @buffer?

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
        return unless results?

        for res in results
          {bufferRange: range, match: color} = res
          colorObject = new Color(color)

          if marker = @findMarker(color, range)
            delete markersToRemoveById[marker.id]
          else
            marker = @createMarker(color, colorObject, range)

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
