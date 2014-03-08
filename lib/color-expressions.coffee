
Color = require './color-model'

int = '\\d+'
float = "#{int}(?:\\.#{int})?"
percent = "#{float}%"
intOrPercent = "(#{int}|#{percent})"
comma = '\\s*,\\s*'
hexa = '[\\da-fA-F]'

strip = (str) -> str.replace(/\s+/g, '')

parseIntOrPercent = (value) ->
  if value.indexOf('%') isnt -1
    value = Math.round(parseFloat(value) * 2.55)
  else
    value = parseInt(value)

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
