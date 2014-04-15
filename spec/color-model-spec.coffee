Color = require '../lib/color-model'

require '../lib/color-expressions'

itShouldParseTheColor = (expr, red=0, green=0, blue=0, alpha=1) ->
  msg = "should create a color with red=#{red}, green=#{green}, blue=#{blue} and alpha=#{alpha}"
  desc = expr.replace(/#/g, '')

  describe "created with #{desc}", ->
    beforeEach ->
      expect(Color.canHandle(expr)).toBeTruthy()

    it msg, ->
      color = new Color(expr)

      expect(Math.round(color.red)).toEqual(red)
      expect(Math.round(color.green)).toEqual(green)
      expect(Math.round(color.blue)).toEqual(blue)
      expect(color.alpha).toBeCloseTo(alpha, 0.001)

describe 'Color', ->
  itShouldParseTheColor('#ff7f00', 255, 127, 0)
  itShouldParseTheColor('#f70', 255, 119, 0)

  itShouldParseTheColor('0xff7f00', 255, 127, 0)
  itShouldParseTheColor('0x00ff7f00', 255, 127, 0, 0)

  itShouldParseTheColor('rgb(255,127,0)', 255, 127, 0)
  itShouldParseTheColor('rgba(255,127,0,0)', 255, 127, 0, 0)

  itShouldParseTheColor('hsl(200,50%,50%)', 64, 149, 191)
  itShouldParseTheColor('hsla(200,50%,50%,0)', 64, 149, 191, 0)

  itShouldParseTheColor('hsv(200,50%,50%)', 64, 106, 128)
  itShouldParseTheColor('hsva(200,50%,50%,0)', 64, 106, 128, 0)

  itShouldParseTheColor('cyan', 0, 255, 255)

  itShouldParseTheColor('darken(cyan, 20%)', 0, 204, 204)
  itShouldParseTheColor('lighten(cyan, 20%)', 51, 255, 255)

  itShouldParseTheColor('transparentize(cyan, 0.5)', 0, 255, 255, 0.5)
  itShouldParseTheColor('transparentize(cyan, 50%)', 0, 255, 255, 0.5)
  itShouldParseTheColor('fadein(cyan, 0.5)', 0, 255, 255, 0.5)

  itShouldParseTheColor('opacify(0x7800FFFF, 0.5)', 0, 255, 255, 1)
  itShouldParseTheColor('opacify(0x7800FFFF, 50%)', 0, 255, 255, 1)
  itShouldParseTheColor('fadeout(0x7800FFFF, 0.5)', 0, 255, 255, 1)

  itShouldParseTheColor('saturate(#855, 20%)', 158, 63, 63)
  itShouldParseTheColor('saturate(#855, 0.2)', 158, 63, 63)

  itShouldParseTheColor('desaturate(#9e3f3f, 20%)', 136, 85, 85)
  itShouldParseTheColor('desaturate(#9e3f3f, 0.2)', 136, 85, 85)

  itShouldParseTheColor('grayscale(#9e3f3f)', 111, 111, 111)
  itShouldParseTheColor('greyscale(#9e3f3f)', 111, 111, 111)

  itShouldParseTheColor('invert(#9e3f3f)', 97, 192, 192)

  itShouldParseTheColor('adjust-hue(#811, 45deg)', 136, 106, 17)
  itShouldParseTheColor('adjust-hue(#811, -45deg)', 136, 17, 106)

  itShouldParseTheColor('mix(#f00, #00f)', 127, 0, 127)
  itShouldParseTheColor('mix(#f00, #00f, 25%)', 63, 0, 191)

  itShouldParseTheColor('tint(#fd0cc7,66%)', 254, 172, 235)
  itShouldParseTheColor('shade(#fd0cc7,66%)', 86, 4, 67)
