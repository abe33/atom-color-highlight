
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
Color.addExpression ///\#(#{hexa}{6})(?!\d)///, (color, expression) ->
  [m, hexa] = @regexp.exec(expression)
  colorAsInt = parseInt(hexa.replace('#', ''), 16)

  color.red = colorAsInt >> 16 & 0xff
  color.green = colorAsInt >> 8 & 0xff
  color.blue = colorAsInt & 0xff
  color.alpha = 1

# #000
Color.addExpression ///\#(#{hexa}{3})(?!\d)///, (color, expression) ->
  [m, hexa] = @regexp.exec(expression)
  colorAsInt = parseInt(hexa.replace('#', ''), 16)

  color.red = (colorAsInt >> 8 & 0xf) * 17
  color.green = (colorAsInt >> 4 & 0xf) * 17
  color.blue = (colorAsInt & 0xf) * 17
  color.alpha = 1

# 0xFF000000
Color.addExpression ///0x(#{hexa}{8})(?!\d)///, (color, expression) ->
  [m, hexa] = @regexp.exec(expression)
  colorAsInt = parseInt(hexa.replace('0x', ''), 16)

  color.alpha = (colorAsInt >> 24 & 0xff) / 255
  color.red = colorAsInt >> 16 & 0xff
  color.green = colorAsInt >> 8 & 0xff
  color.blue = colorAsInt & 0xff

# 0x000000
Color.addExpression ///0x(#{hexa}{6})(?!\d)///, (color, expression) ->
  [m, hexa] = @regexp.exec(expression)
  colorAsInt = parseInt(hexa.replace('0x', ''), 16)

  color.red = colorAsInt >> 16 & 0xff
  color.green = colorAsInt >> 8 & 0xff
  color.blue = colorAsInt & 0xff
  color.alpha = 1

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
