
Color = require './color-model'

int = '\\d+'
float = "#{int}(?:\\.#{int})?"
percent = "#{float}%"
intOrPercent = "(#{int}|#{percent})"
floatOrPercent = "(#{float}|#{percent})"
comma = '\\s*,\\s*'
notQuote = "[^\"'\n]*"
hexa = '[\\da-fA-F]'

strip = (str) -> str.replace(/\s+/g, '')
clamp = (n) -> Math.min(1, Math.max(0, n))
clampInt = (n, max=100) -> Math.min(max, Math.max(0, n))

parseIntOrPercent = (value) ->
  if value.indexOf('%') isnt -1
    value = Math.round(parseFloat(value) * 2.55)
  else
    value = parseInt(value)

parseFloatOrPercent = (amount) ->
  if amount.indexOf('%') isnt -1
    parseFloat(amount) / 100
  else
    parseFloat(amount)

# darken(#666666, 20%)
Color.addExpression "darken\\((#{notQuote}),\\s*(#{percent})\\)", (color, expression) ->
  [m, subexpr, amount] = @onigRegExp.search(expression)

  subexpr = subexpr.match
  amount = parseFloat(amount.match)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, s, clampInt(l - l * (amount / 100))]
    color.alpha = baseColor.alpha

# lighten(#666666, 20%)
Color.addExpression "lighten\\((#{notQuote}),\\s*(#{percent})\\)", (color, expression) ->
  [m, subexpr, amount] = @onigRegExp.search(expression)

  subexpr = subexpr.match
  amount = parseFloat(amount.match)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, s, clampInt(l + l * (amount / 100))]
    color.alpha = baseColor.alpha

# transparentize(#ffffff, 0.5)
# transparentize(#ffffff, 50%)
Color.addExpression "transparentize\\((#{notQuote}),\\s*(#{floatOrPercent})\\)", (color, expression) ->
  [m, subexpr, amount] = @onigRegExp.search(expression)

  subexpr = subexpr.match
  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    color.rgb = baseColor.rgb
    color.alpha = clamp(baseColor.alpha - amount)

# opacify(0x78ffffff, 0.5)
# opacify(0x78ffffff, 50%)
Color.addExpression "opacify\\((#{notQuote}),\\s*(#{floatOrPercent})\\)", (color, expression) ->
  [m, subexpr, amount] = @onigRegExp.search(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    color.rgb = baseColor.rgb
    color.alpha = clamp(baseColor.alpha + amount)


# desaturate(#855, 20%)
# desaturate(#855, 0.2)
Color.addExpression "desaturate\\((#{notQuote}),\\s*(#{floatOrPercent})\\)", (color, expression) ->
  [m, subexpr, amount] = @onigRegExp.search(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, clampInt(s - amount * 100), l]
    color.alpha = baseColor.alpha

# saturate(#855, 20%)
# saturate(#855, 0.2)
Color.addExpression "saturate\\((#{notQuote}),\\s*(#{floatOrPercent})\\)", (color, expression) ->
  [m, subexpr, amount] = @onigRegExp.search(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, clampInt(s + amount * 100), l]
    color.alpha = baseColor.alpha

Color.addExpression "gr(a|e)yscale\\((#{notQuote})\\)", (color, expression) ->
  [m, _, subexpr] = @onigRegExp.search(expression)
  subexpr = subexpr.match

  if Color.canHandle(subexpr)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, 0, l]
    color.alpha = baseColor.alpha

Color.addExpression "invert\\((#{notQuote})\\)", (color, expression) ->
  [m, subexpr] = @onigRegExp.search(expression)
  subexpr = subexpr.match

  if Color.canHandle(subexpr)
    baseColor = new Color(subexpr)
    [r,g,b] = baseColor.rgb

    console.log r, g, b

    color.rgb = [255 - r, 255 - g, 255 - b]
    color.alpha = baseColor.alpha

# #000000
Color.addExpression "#(#{hexa}{6})(?!#{hexa})", (color, expression) ->
  [m, hexa] = @onigRegExp.search(expression)

  color.hex = hexa.match

# #000
Color.addExpression "#(#{hexa}{3})(?!#{hexa})", (color, expression) ->
  [m, hexa] = @onigRegExp.search(expression)
  colorAsInt = parseInt(hexa.match, 16)

  color.red = (colorAsInt >> 8 & 0xf) * 17
  color.green = (colorAsInt >> 4 & 0xf) * 17
  color.blue = (colorAsInt & 0xf) * 17

# 0xFF000000
Color.addExpression "0x(#{hexa}{8})(?!#{hexa})", (color, expression) ->
  [m, hexa] = @onigRegExp.search(expression)

  color.hexARGB = hexa.match

# 0x000000
Color.addExpression "0x(#{hexa}{6})(?!#{hexa})", (color, expression) ->
  [m, hexa] = @onigRegExp.search(expression)

  color.hex = hexa.match

# rgb(0,0,0)
Color.addExpression strip("
  rgb\\(\\s*
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
  \\)
"), (color, expression) ->
  [m,r,g,b] = @onigRegExp.search(expression)

  color.red = parseIntOrPercent(r.match)
  color.green = parseIntOrPercent(g.match)
  color.blue = parseIntOrPercent(b.match)
  color.alpha = 1

# rgba(0,0,0,1)
Color.addExpression strip("
  rgba\\(\\s*
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
    #{comma}
    (#{float})
  \\)
"), (color, expression) ->
  [m,r,g,b,a] = @onigRegExp.search(expression)

  color.red = parseIntOrPercent(r.match)
  color.green = parseIntOrPercent(g.match)
  color.blue = parseIntOrPercent(b.match)
  color.alpha = parseFloat(a.match)

# hsl(0,0%,0%)
Color.addExpression strip("
  hsl\\(\\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
  \\)
"), (color, expression) ->
  [m,h,s,l] = @onigRegExp.search(expression)

  color.hsl = [
    parseInt(h.match)
    parseFloat(s.match)
    parseFloat(l.match)
  ]
  color.alpha = 1

# hsla(0,0%,0%,1)
Color.addExpression strip("
  hsla\\(\\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
    #{comma}
    (#{float})
  \\)
"), (color, expression) ->
  [m,h,s,l,a] = @onigRegExp.search(expression)

  color.hsl = [
    parseInt(h.match)
    parseFloat(s.match)
    parseFloat(l.match)
  ]
  color.alpha = parseFloat(a.match)

# hsv(0,0%,0%)
Color.addExpression strip("
  hsv\\(\\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
  \\)
"), (color, expression) ->
  [m,h,s,v] = @onigRegExp.search(expression)

  color.hsv = [
    parseInt(h.match)
    parseFloat(s.match)
    parseFloat(v.match)
  ]
  color.alpha = 1

# hsva(0,0%,0%,1)
Color.addExpression strip("
  hsva\\(\\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
    #{comma}
    (#{float})
  \\)
"), (color, expression) ->
  [m,h,s,v,a] = @onigRegExp.search(expression)

  color.hsv = [
    parseInt(h.match)
    parseFloat(s.match)
    parseFloat(v.match)
  ]
  color.alpha = parseFloat(a.match)


# vec4(0,0,0,1)
Color.addExpression strip("
  vec4\\(\\s*
    (#{float})
    #{comma}
    (#{float})
    #{comma}
    (#{float})
    #{comma}
    (#{float})
  \\)
"), (color, expression) ->
  [m,h,s,l,a] = @onigRegExp.search(expression)

  color.rgba = [
    parseFloat(h.match) * 255
    parseFloat(s.match) * 255
    parseFloat(l.match) * 255
    parseFloat(a.match)
  ]

# black
colors = Object.keys(Color.namedColors)

colorRegexp = "\\b(?<![\\.\\$@-])(?i)(#{colors.join('|')})(?-i)(?![-\\.:=])\\b"

Color.addExpression colorRegexp, (color, expression) ->
  [m,name] = @onigRegExp.search(expression)

  color.name = name.match
