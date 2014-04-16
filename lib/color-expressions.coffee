
Color = require './color-model'

int = '\\d+'
float = "#{int}(?:\\.#{int})?"
percent = "#{float}%"
intOrPercent = "(#{int}|#{percent})"
floatOrPercent = "(#{float}|#{percent})"
comma = '\\s*,\\s*'
notQuote = "[^\"'\n]*"
hexa = '[\\da-fA-F]'
ps = '\\(\\s*'
pe = '\\s*\\)'

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
Color.addExpression "darken#{ps}(#{notQuote})#{comma}(#{percent})#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloat(amount.match)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, s, clampInt(l - l * (amount / 100))]
    color.alpha = baseColor.alpha

# lighten(#666666, 20%)
Color.addExpression "lighten#{ps}(#{notQuote})#{comma}(#{percent})#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloat(amount.match)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, s, clampInt(l + l * (amount / 100))]
    color.alpha = baseColor.alpha

# transparentize(#ffffff, 0.5)
# transparentize(#ffffff, 50%)
# fadein(#ffffff, 0.5)
Color.addExpression "(transparentize|fadein)#{ps}(#{notQuote})#{comma}(#{floatOrPercent})#{pe}", (color, expression) ->
  [_, _, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    color.rgb = baseColor.rgb
    color.alpha = clamp(baseColor.alpha - amount)

# opacify(0x78ffffff, 0.5)
# opacify(0x78ffffff, 50%)
# fadeout(0x78ffffff, 0.5)
Color.addExpression "(opacify|fadeout)#{ps}(#{notQuote})#{comma}(#{floatOrPercent})#{pe}", (color, expression) ->
  [_, _, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    color.rgb = baseColor.rgb
    color.alpha = clamp(baseColor.alpha + amount)

# adjust-hue(#855, 60deg)
Color.addExpression "adjust-hue#{ps}(#{notQuote})#{comma}(-?#{int})deg#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [(h + amount) % 360, s, l]
    color.alpha = baseColor.alpha

# mix(#f00, #00F, 25%)
Color.addExpression "mix#{ps}((#{notQuote})#{comma} (#{notQuote})#{comma}(#{floatOrPercent})|(#{notQuote})#{comma}(#{notQuote}))#{pe}", (color, expression) ->
  [_, _, color1A, color2A, amount, _, color1B, color2B] = @onigRegExp.searchSync(expression)

  if color1A.match.length > 0
    color1 = color1A.match
    color2 = color2A.match
    amount = parseFloatOrPercent amount?.match
  else
    color1 = color1B.match
    color2 = color2B.match
    amount = 0.5

  if Color.canHandle(color1) and Color.canHandle(color2) and not isNaN(amount)
    baseColor1 = new Color(color1)
    baseColor2 = new Color(color2)

    color.rgba = Color.mixColors(baseColor1, baseColor2, amount).rgba

# tint(red, 50%)
Color.addExpression "tint#{ps}(#{notQuote})#{comma}(#{floatOrPercent})#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloatOrPercent(amount.match)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    white = new Color('white')

    color.rgba = Color.mixColors(white, baseColor, amount).rgba

# shade(red, 50%)
Color.addExpression "shade#{ps}(#{notQuote})#{comma}(#{floatOrPercent})#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match
  amount = parseFloatOrPercent(amount.match)

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    black = new Color('black')

    color.rgba = Color.mixColors(black, baseColor, amount).rgba


# desaturate(#855, 20%)
# desaturate(#855, 0.2)
Color.addExpression "desaturate#{ps}(#{notQuote})#{comma}(#{floatOrPercent})#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, clampInt(s - amount * 100), l]
    color.alpha = baseColor.alpha

# saturate(#855, 20%)
# saturate(#855, 0.2)
Color.addExpression "saturate#{ps}(#{notQuote})#{comma}(#{floatOrPercent})#{pe}", (color, expression) ->
  [_, subexpr, amount] = @onigRegExp.searchSync(expression)

  subexpr = subexpr.match

  amount = parseFloatOrPercent amount.match

  if Color.canHandle(subexpr) and not isNaN(amount)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, clampInt(s + amount * 100), l]
    color.alpha = baseColor.alpha

Color.addExpression "gr(a|e)yscale#{ps}(#{notQuote})#{pe}", (color, expression) ->
  [_, _, subexpr] = @onigRegExp.searchSync(expression)
  subexpr = subexpr.match

  if Color.canHandle(subexpr)
    baseColor = new Color(subexpr)
    [h,s,l] = baseColor.hsl

    color.hsl = [h, 0, l]
    color.alpha = baseColor.alpha

Color.addExpression "invert#{ps}(#{notQuote})#{pe}", (color, expression) ->
  [_, subexpr] = @onigRegExp.searchSync(expression)
  subexpr = subexpr.match

  if Color.canHandle(subexpr)
    baseColor = new Color(subexpr)
    [r,g,b] = baseColor.rgb

    color.rgb = [255 - r, 255 - g, 255 - b]
    color.alpha = baseColor.alpha

# #000000
Color.addExpression "#(#{hexa}{6})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @onigRegExp.searchSync(expression)

  color.hex = hexa.match

# #000
Color.addExpression "#(#{hexa}{3})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @onigRegExp.searchSync(expression)
  colorAsInt = parseInt(hexa.match, 16)

  color.red = (colorAsInt >> 8 & 0xf) * 17
  color.green = (colorAsInt >> 4 & 0xf) * 17
  color.blue = (colorAsInt & 0xf) * 17

# 0xFF000000
Color.addExpression "0x(#{hexa}{8})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @onigRegExp.searchSync(expression)

  color.hexARGB = hexa.match

# 0x000000
Color.addExpression "0x(#{hexa}{6})(?!#{hexa})", (color, expression) ->
  [_, hexa] = @onigRegExp.searchSync(expression)

  color.hex = hexa.match

# rgb(0,0,0)
Color.addExpression strip("
  rgb#{ps}\\s*
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
  #{pe}
"), (color, expression) ->
  [_,r,g,b] = @onigRegExp.searchSync(expression)

  color.red = parseIntOrPercent(r.match)
  color.green = parseIntOrPercent(g.match)
  color.blue = parseIntOrPercent(b.match)
  color.alpha = 1

# rgba(0,0,0,1)
Color.addExpression strip("
  rgba#{ps}\\s*
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
    #{comma}
    (#{float})
  #{pe}
"), (color, expression) ->
  [_,r,g,b,a] = @onigRegExp.searchSync(expression)

  color.red = parseIntOrPercent(r.match)
  color.green = parseIntOrPercent(g.match)
  color.blue = parseIntOrPercent(b.match)
  color.alpha = parseFloat(a.match)

# hsl(0,0%,0%)
Color.addExpression strip("
  hsl#{ps}\\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
  #{pe}
"), (color, expression) ->
  [_,h,s,l] = @onigRegExp.searchSync(expression)

  color.hsl = [
    parseInt(h.match)
    parseFloat(s.match)
    parseFloat(l.match)
  ]
  color.alpha = 1

# hsla(0,0%,0%,1)
Color.addExpression strip("
  hsla#{ps}\\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
    #{comma}
    (#{float})
  #{pe}
"), (color, expression) ->
  [_,h,s,l,a] = @onigRegExp.searchSync(expression)

  color.hsl = [
    parseInt(h.match)
    parseFloat(s.match)
    parseFloat(l.match)
  ]
  color.alpha = parseFloat(a.match)

# hsv(0,0%,0%)
Color.addExpression strip("
  hsv#{ps}\\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
  #{pe}
"), (color, expression) ->
  [_,h,s,v] = @onigRegExp.searchSync(expression)

  color.hsv = [
    parseInt(h.match)
    parseFloat(s.match)
    parseFloat(v.match)
  ]
  color.alpha = 1

# hsva(0,0%,0%,1)
Color.addExpression strip("
  hsva#{ps}\\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
    #{comma}
    (#{float})
  #{pe}
"), (color, expression) ->
  [_,h,s,v,a] = @onigRegExp.searchSync(expression)

  color.hsv = [
    parseInt(h.match)
    parseFloat(s.match)
    parseFloat(v.match)
  ]
  color.alpha = parseFloat(a.match)


# vec4(0,0,0,1)
Color.addExpression strip("
  vec4#{ps}\\s*
    (#{float})
    #{comma}
    (#{float})
    #{comma}
    (#{float})
    #{comma}
    (#{float})
  #{pe}
"), (color, expression) ->
  [_,h,s,l,a] = @onigRegExp.searchSync(expression)

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
  [_,name] = @onigRegExp.searchSync(expression)

  color.name = name.match
