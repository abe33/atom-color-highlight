
Color = require './color-model'

int = '\\d+'
float = "#{int}(?:\\.#{int})?"
percent = "#{float}%"
intOrPercent = "(#{int}|#{percent})"
comma = '\\s*,\\s*'
hexa = '[\\da-fA-F]'

parseIntOrPercent = (value) ->
  if value.indexOf('%') isnt -1
    value = Math.round(parseFloat(value) * 2.55)
  else
    value = parseInt(value)

# #000000
Color.addExpression ///\#(#{hexa}{6})(?!#{hexa})///, (color, expression) ->
  [m, hexa] = @regexp.exec(expression)

  color.hex = hexa.replace('#', '')

# #000
Color.addExpression ///\#(#{hexa}{3})(?!#{hexa})///, (color, expression) ->
  [m, hexa] = @regexp.exec(expression)
  colorAsInt = parseInt(hexa.replace('#', ''), 16)

  color.red = (colorAsInt >> 8 & 0xf) * 17
  color.green = (colorAsInt >> 4 & 0xf) * 17
  color.blue = (colorAsInt & 0xf) * 17

# 0xFF000000
Color.addExpression ///0x(#{hexa}{8})(?!#{hexa})///, (color, expression) ->
  [m, hexa] = @regexp.exec(expression)

  color.hexARGB = hexa.replace('0x', '')

# 0x000000
Color.addExpression ///0x(#{hexa}{6})(?!#{hexa})///, (color, expression) ->
  [m, hexa] = @regexp.exec(expression)

  color.hex = hexa.replace('0x', '')

# rgb(0,0,0)
Color.addExpression ///
  rgb\(\s*
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
  \)
///, (color, expression) ->
  [m,r,g,b] = @regexp.exec(expression)

  color.red = parseIntOrPercent(r)
  color.green = parseIntOrPercent(g)
  color.blue = parseIntOrPercent(b)
  color.alpha = 1

# rgba(0,0,0,1)
Color.addExpression ///
  rgba\(\s*
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
    #{comma}
    #{intOrPercent}
    #{comma}
    (#{float})
  \)
///, (color, expression) ->
  [m,r,g,b,a] = @regexp.exec(expression)

  color.red = parseIntOrPercent(r)
  color.green = parseIntOrPercent(g)
  color.blue = parseIntOrPercent(b)
  color.alpha = parseFloat(a)

# hsl(0,0%,0%)
Color.addExpression ///
  hsl\(\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
  \)
///, (color, expression) ->
  [m,h,s,l] = @regexp.exec(expression)

  color.hsl = [
    parseInt(h)
    parseFloat(s)
    parseFloat(l)
  ]
  color.alpha = 1

# hsla(0,0%,0%,1)
Color.addExpression ///
  hsla\(\s*
    (#{int})
    #{comma}
    (#{percent})
    #{comma}
    (#{percent})
    #{comma}
    (#{float})
  \)
///, (color, expression) ->
  [m,h,s,l,a] = @regexp.exec(expression)

  color.hsl = [
    parseInt(h)
    parseFloat(s)
    parseFloat(l)
  ]
  color.alpha = parseFloat(a)

# vec4(0,0,0,1)

Color.addExpression ///
  vec4\(\s*
    (#{float})
    #{comma}
    (#{float})
    #{comma}
    (#{float})
    #{comma}
    (#{float})
  \)
///, (color, expression) ->
  [m,h,s,l,a] = @regexp.exec(expression)

  color.rgba = [
    parseFloat(h * 255)
    parseFloat(s * 255)
    parseFloat(l * 255)
    parseFloat(a)
  ]

# black

colors = Object.keys(Color.namedColors)

colorRegexp = ///\b(#{colors.join('|')})\b///i

Color.addExpression colorRegexp, (color, expression) ->
  [m,name] = @regexp.exec(expression)

  color.name = name
