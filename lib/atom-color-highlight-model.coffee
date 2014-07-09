_ = require 'underscore-plus'
Q = require 'q'
{Emitter, Subscriber} = require 'emissary'
Color = require 'pigments'
Range = null

flatten = (array) ->
  b = []
  b = b.concat a for a in array
  b.filter (e) -> e?

merge = (array) ->
  o = {}
  for obj in array
    o[k] = v for k,v of obj
  o

module.exports =
class AtomColorHighlightModel
  Emitter.includeInto(this)
  Subscriber.includeInto(this)

  @Color: Color

  @markerClass: 'color-highlight'
  @bufferRange: [[0,0], [Infinity,Infinity]]

  constructor: (@editor, @buffer) ->
    @changes = []
    @markers = []

    Range = @buffer.constructor.Range

    finder = atom.packages.getLoadedPackage('project-palette-finder')
    if finder?
      module = require(finder.path)
      Color = module.constructor.Color
      @subscribe module, 'palette:ready', @update

    @constructor.Color = Color

  init: ->
    return unless @buffer?

    @subscribeToBuffer()
    @updateAll()

  dispose: ->
    @unsubscribe()
    @unsubscribeFromBuffer() if @buffer?

  update: =>
    promise = Q.fcall ->

    allDestroyedMarkers = []
    allCreatedMarkers = []
    dirtyVariables = []

    if @changes.length
      {oldRanges, newRanges} = @packChanges(@changes)
      @changes = []

      promise = promise.then =>
        @destroyVariablesInRanges(oldRanges)
      .then (destroyedVariables) =>
        dirtyVariables = dirtyVariables.concat Object.keys(destroyedVariables)

        if dirtyVariables.length
          re = ///\b#{dirtyVariables.join('|')}\b///
          @destroyMarkersWithRegExp(re)
        else
          []

      .then (destroyedMarkers) =>
        newRanges.push marker.bufferMarker.range for marker in destroyedMarkers
        newRanges = newRanges.map (range) =>
          @expandRangeToCompleteLines(range)

        allDestroyedMarkers = allDestroyedMarkers.concat(destroyedMarkers)
        @destroyMarkersInRanges(oldRanges)

      .then (destroyedMarkers) =>
        allDestroyedMarkers = allDestroyedMarkers.concat(destroyedMarkers)
        @findVariablesInRanges(newRanges)

      .then (foundVariables) =>
        console.log newRanges, foundVariables, @variables
        @searchForVariablesUsage(foundVariables, newRanges)

      .then (foundRanges) =>
        newRanges = newRanges.concat foundRanges.map (range) =>
          @expandRangeToCompleteLines(range)

        @destroyMarkersInRanges(foundRanges)

      .then (destroyedMarkers) =>
        allDestroyedMarkers = allDestroyedMarkers.concat(destroyedMarkers)
        @createMarkersInRanges(newRanges)

      .then (createdMarkers) =>
        allCreatedMarkers = allCreatedMarkers.concat createdMarkers

        # console.log allDestroyedMarkers
        # console.log createdMarkers
        @emit('markers:destroyed', allDestroyedMarkers) if allDestroyedMarkers.length > 0
        @emit('markers:created', allCreatedMarkers) if allCreatedMarkers.length > 0

      .fail (reason) ->
        console.log reason
    else
      promise = promise.then => @updateAll()

    promise.fail (reason) ->
      console.log reason

    promise

  searchForVariablesUsage: (createdVariables, excludedRanges=[]) ->
    text = @buffer.getText()
    ranges = []
    keys = Object.keys(createdVariables)

    return ranges unless keys.length

    re = ///\b#{keys.join('|')}\b///g
    n = 100

    while (match = re.exec(text)) and n > 0
      start = match.index
      end = start + match[0].length

      range = {
        start: @buffer.positionForCharacterIndex(start)
        end: @buffer.positionForCharacterIndex(end)
      }

      ranges.push range unless @rangesContains(excludedRanges, range)
      n--

    if n <= 0
      console.warn 'Infinite Loop Detected'
      console.log re, match

    ranges

  rangesContains: (ranges, tested) ->
    return true for range in ranges when range.containsRange(tested)
    false

  updateAll: ->
    @destroyVariables()
    .then(@findVariables)
    .then(@destroyMarkers)
    .then (destroyedMarkers) =>
      @emit('markers:destroyed', destroyedMarkers) if destroyedMarkers.length
    .then(@createMarkers)
    .then (createdMarkers) =>
      @emit('markers:created', createdMarkers) if createdMarkers?

  packChanges: (changes) ->
    oldRanges = []
    newRanges = []

    for change in changes
      {oldRange: changeOldRange, newRange: changeNewRange} = change

      if oldRanges.length
        for oldRange, i in oldRanges
          if oldRange.containsRange changeOldRange
            continue
          else if oldRange.intersectsWith changeOldRange
            oldRanges[i] = oldRange.union(changeOldRange)
          else
            oldRanges.push changeOldRange

        for newRange, i in newRanges
          if newRange.containsRange changeOldRange
            continue
          else if newRange.intersectsWith changeNewRange
            newRanges[i] = newRange.union(changeNewRange)
          else
            newRanges.push changeNewRange

      else
        oldRanges.push change.oldRange
        newRanges.push change.newRange

    {oldRanges, newRanges}

  subscribeToBuffer: ->
    @subscribe @buffer, 'contents-modified', @update
    @subscribe @buffer, 'changed', @registerChanges

  unsubscribeFromBuffer: ->
    @unsubscribe @buffer, 'contents-modified', @update
    @unsubscribe @buffer, 'changed', @registerChanges
    @buffer = null

  registerChanges: (changes) =>
    @changes.push changes

  destroyVariables: => @destroyVariablesInRange()
  destroyVariablesInRange: (range=@constructor.bufferRange) =>
    range = Range.fromObject(range)
    destroyedVariables = {}
    remainingVariables = {}

    for variable, props of @variables
      {range: variableRange} = props
      variableRange = Range.fromObject variableRange

      if range.containsRange(variableRange) or range.intersectsWith(variableRange)
        destroyedVariables[variable] = props
      else
        remainingVariables[variable] = props

    @variables = remainingVariables

    Q.fcall -> destroyedVariables

  destroyVariablesInRanges: (ranges) ->
    Q.all(ranges.map (range) => @destroyVariablesInRange(range)).then (results) ->
      merge results

  findVariables: => @findVariablesInRange()
  findVariablesInRange: (range=@constructor.bufferRange) =>
    range = Range.fromObject(range)

    Color.scanBufferForColorVariablesInRange(@buffer, range)
    .then (variables) =>
      @variables[k] = v for k,v of variables
      @variables

  findVariablesInRanges: (ranges) ->
    Q.all(ranges.map (range) => @findVariablesInRange(range)).then (results) ->
      merge results

  destroyMarkers: => @destroyMarkersInRange()
  destroyMarkersInRange: (range=@constructor.bufferRange) =>
    range = Range.fromObject(range)

    destroyedMarkers = []
    @markers = @markers.filter (marker) ->
      markerRange = marker.getScreenRange()

      if range.containsRange(markerRange) or range.intersectsWith(markerRange)
        marker.destroy()
        destroyedMarkers.push marker
        return false

      true

    Q.fcall -> destroyedMarkers

  destroyMarkersInRanges: (ranges) ->
    Q.all(ranges.map (range) => @destroyMarkersInRange(range)).then (results) ->
      flatten results

  destroyMarkersWithRegExp: (re) ->
    Q.fcall =>
      destroyedMarkers = []

      @markers = @markers.filter (marker) =>
        return false unless marker.bufferMarker?
        if re.test marker.bufferMarker.properties.color
          marker.destroy()
          destroyedMarkers.push marker
          return false

        true

      destroyedMarkers

  createMarkers: => @createMarkersInRange()
  createMarkersInRange: (range=@constructor.bufferRange) =>
    range = Range.fromObject(range)

    Color.scanBufferForColorsInRange(@buffer, range, @variables)
    .then (results) =>
      return [] unless results

      createdMarkers = []

      for res in results
        {bufferRange: range, match, color} = res
        marker = @createMarker(match, color, range)
        continue unless marker?
        @markers.push marker
        createdMarkers.push marker

      createdMarkers

  createMarkersInRanges: (ranges) ->
    Q.all(ranges.map (range) => @createMarkersInRange(range)).then (results) ->
      flatten results

  createMarker: (color, colorObject, range) ->
    return if @findMarker(color, range)

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

  findMarker: (color, range) ->
    attributes =
      type: @constructor.markerClass
      color: color
      startPosition: range.start
      endPosition: range.end

    _.find @editor.findMarkers(attributes), (marker) -> marker.isValid()

  expandRangeToCompleteLines: (range) ->
    array = if range.push?
      [[range[0][0], 0], [range[1][0], Infinity]]
    else
      [[range.start.row, 0], [range.end.row, Infinity]]

    @buffer.constructor.Range.fromObject array
