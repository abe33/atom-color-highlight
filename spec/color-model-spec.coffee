Color = require '../lib/color-model'

require '../lib/color-expressions'

console.log Color.colorExpressions

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
      expect(color.alpha).toEqual(alpha)

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

  c = Math.round(255 * 0.8)
  itShouldParseTheColor('darken(cyan, 20%)', 0, c, c)
  itShouldParseTheColor('lighten(cyan, 20%)', 51, 255, 255)
  itShouldParseTheColor('transparentize(cyan, 0.5)', 0, 255, 255, 0.5)
