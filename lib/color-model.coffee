_ = require 'underscore-plus'
PropertyAccessors = require 'property-accessors'
ColorConversions = require './color-conversions'

# Public: The {Color} class represent a RGBA color with its four components
# `red`, `green`, `blue` and `alpha`. Internally the color components are
# stored as in an array, the red component stored at index `0`, the green
# component at index `1` and so on.
module.exports =
class Color
  PropertyAccessors.includeInto(this)
  ColorConversions.extend(this)

  # The {Array} where color expression handlers are stored
  @colorExpressions: []

  # Public: Registers a color expression into the {Color} class.
  # The function will create an expression handler with the passed-in
  # arguments.
  #
  # regexp - A {RegExp} that matches the color notation. The
  #          expression can capture groups that will be used later in the
  #          color parsing phase
  # handle - A {Function} that takes a {Color} to modify and the {String}
  #          that matched during the lookup phase
  @addExpression: (regexp, handle) ->
    @colorExpressions.push
      regexp: regexp
      handle: handle
      canHandle: (expression) -> @regexp.test expression

  # Public: Returns a {RegExp} that contains all the registered expressions
  # separated with `|`. This is this regexp that will be used to scan buffers
  # and find color expressions.
  @colorRegexp: ->
    src = @colorExpressions.map((expr) -> "(#{expr.regexp.source})" ).join('|')
    new RegExp(src, 'g')

  # A two dimensional {Array} storing the name of a component with its index.
  @colorComponents: [
    [ 'red',   0 ]
    [ 'green', 1 ]
    [ 'blue',  2 ]
    [ 'alpha', 3 ]
  ]

  # Public: The `red`, `green`, `blue` and `alpha` components accessors.
  # They are generated using the `colorComponents` array.
  @colorComponents.forEach ([component, index]) =>
    @::accessor component, {
      get: -> @[index]
      set: (component) -> @[index] = component
    }

  # Public: The `rgb` accessor gives access to the color as an {Array}
  # of its components. This array takes the form `[red, green, blue]`.
  # Using the `rgb` setter doesn't modify the alpha component of the color.
  @::accessor 'rgb', {
    get: -> [@red, @green, @blue]
    set: ([@red, @green, @blue]) ->
  }

  # Public: The `rgb` accessor gives access to the color as an {Array}
  # of its components. This array takes the form `[red, green, blue, alpha]`.
  @::accessor 'rgba', {
    get: -> [@red, @green, @blue, @alpha]
    set: ([@red, @green, @blue, @alpha]) ->
  }

  # Public: The `hsl` accessor gives access to the color in the
  # HSV color space. This color space is reprensented as an {Array}
  # such as `[hue, saturation, value]`.
  # Using the `hsl` setter doesn't modify the alpha component of the color.
  @::accessor 'hsl', {
    get: -> @constructor.rgbToHSV(@red, @green, @blue)
    set: (hsl) ->
      [@red, @green, @blue] = @constructor.hsvToRGB.apply(@constructor, hsl)
  }

  # Public: The `hex` accessor gives access to the color in hexadecimal
  # notation. This notation is represented as a {String} such as `RRGGBB`.
  # Using the `hex` setter doesn't modify the alpha component of the color.
  @::accessor 'hex', {
    get: -> @constructor.rgbToHex(@red, @green, @blue)
    set: (hex) ->
      [@red, @green, @blue] = @constructor.hexToRGB(hex)
  }

  # Public: The `hexARGB` accessor gives access to the color in hexadecimal
  # notation. This notation is represented as a {String} such as `AARRGGBB`.
  @::accessor 'hexARGB', {
    get: -> @constructor.rgbToHexARGB(@red, @green, @blue, @alpha)
    set: (hex) ->
      [@red, @green, @blue, @alpha] = @constructor.hexARGBToRGB(hex)
  }

  # Public: Read Only: The length of the color, always 4.
  @::accessor 'length', get: -> 4

  # Public: A {Color} object can be created with any of the expressions it
  # supports. Each expression handler is tested against the expression and
  # the first to match is used.
  constructor: (colorExpression = null) ->
    [@red, @green, @blue, @alpha] = [0, 0, 0, 1]

    if colorExpression?
      @constructor.colorExpressions.some (expr) =>
        expr.handle(this, colorExpression) if expr.canHandle(colorExpression)

  # Public: Returns a {String} reprensenting the color with the CSS `rgba`
  # notation.
  toCSS: ->
    "rgba(#{Math.round @red},
          #{Math.round @green},
          #{Math.round @blue},
          #{@alpha})"
