_ = require 'underscore-plus'
PropertyAccessors = require 'property-accessors'
{Emitter} = require 'emissary'
ColorConversions = require './color-conversions'

module.exports =
class Color
  Emitter.includeInto(this)
  PropertyAccessors.includeInto(this)
  ColorConversions.extend(this)

  @colorExpressions: []

  @addExpression: (regexp, handle) ->
    @colorExpressions.push
      regexp: regexp
      handle: handle
      canHandle: (expression) -> @regexp.test expression

  @colorRegexp: ->
    src = @colorExpressions.map((expr) -> "(#{expr.regexp.source})" ).join('|')
    new RegExp src, 'g'

  @colorComponents: [
    [ 'red',   0 ]
    [ 'green', 1 ]
    [ 'blue',  2 ]
    [ 'alpha', 3 ]
  ]

  @colorComponents.forEach ([component,index]) =>
    @::accessor component, {
      get: -> @[index]
      set: (component) -> @[index] = component
    }

  @::accessor 'hsl', {
    get: -> @constructor.rgb2hsv(@red, @green, @blue)
    set: (hsl) ->
      [@red,@green,@blue] = @constructor.hsv2rgb.apply(@constructor, hsl)
  }

  @::accessor 'hex', {
    get: -> @constructor.rgb2hex(@red, @green, @blue)
    set: (hex) ->
      [@red,@green,@blue] = @constructor.hex2rgb(hex)
  }

  @::accessor 'hexARGB', {
    get: -> @constructor.rgb2hexARGB(@red, @green, @blue, @alpha)
    set: (hex) ->
      [@red,@green,@blue,@alpha] = @constructor.hexARGB2rgb(hex)
  }

  constructor: (colorExpression=null) ->
    [@red, @green, @blue, @alpha] = [0, 0, 0, 1]

    if colorExpression?
      @constructor.colorExpressions.some (expr) =>
        expr.handle(this, colorExpression) if expr.canHandle(colorExpression)


  toCSS: -> "rgba(#{Math.round @red}, #{Math.round @green}, #{Math.round @blue}, #{@alpha})"
