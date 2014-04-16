<a name="0.11.1"></a>
# 0.11.1 (2014-04-16)

## Features

- **docs**: updates the changelog

<a name="0.11.0"></a>
# 0.11.0 (2014-04-16)

## Features

- **dependencies**: updates oniguruma version from `1.x` to `2.x`

<a name="0.10.0"></a>
# 0.10.0 (2014-04-16)

## Features

- **functions**: adds support for the following color functions:
  - tint (stylus)
  - shade (stylus)
  - lighten
  - darken
  - transparentize
  - opacify
  - grayscale
  - saturate
  - desaturate
  - adjust-hue
  - invert
  - mix (sass/less)
  - fadein (less)
  - fadeout (less)
  - greyscale (less)

<a name="0.9.0"></a>
# 0.9.0 (2014-04-11)

## Features

- **expressions:**
  - adds support for hsv and hsva expression
  - adds support for `darken`, `lighten` and `transparentize` functions

## Bug Fixes

- **expressions:** previously hsl expressions was treated as in hsv color space

<a name="0.8.0"></a>
# 0.8.0 (2014-03-14)

## Bug Fixes

- **markers:** fixes invalid marker position on update after grammar change
  ([4f11759b](https://github.com/abe33/atom-color-highlight/commit/4f11759bad8e9bfa2a4b956ec56ab53928f802ee),
   [#2](https://github.com/abe33/atom-color-highlight/issues/2))
