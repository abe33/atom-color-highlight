<a name="v0.14.0"></a>
# v0.14.0 (2014-06-03)

## :sparkles: Features

- Add screenshot for live update feature ([259574ea](https://github.com/abe33/atom-color-highlight/commit/259574ea9866999719a79cc5ea97b678ae472df2))
- Add live update of colors derived of a variable from same file ([6ab0d54a](https://github.com/abe33/atom-color-highlight/commit/6ab0d54af430cb9fb7b16000d262fb86d2f3bfc2))
- Implement support for color provided by pigments during scan ([dedf26ff](https://github.com/abe33/atom-color-highlight/commit/dedf26ffcae5bec74e66cbe0583e6fbabd7ad33a))  <br>It enables parsing of colors using variables defined in the
  same file.

<a name="0.13.4"></a>
# 0.13.4 (2014-05-29)

## :bug: Bug Fixes

- Force new pigments version ([57e187e2](https://github.com/abe33/atom-color-highlight/commit/57e187e2228f55160a46d5f982ddf1d1d276b6d8), Closes [#12](https://github.com/abe33/atom-color-highlight/issues/12))

<a name="0.13.3"></a>
# 0.13.3 (2014-05-29)

## :bug: Bug Fixes

- Fix broken view when react editor is enabled ([4be2c7b3](https://github.com/abe33/atom-color-highlight/commit/4be2c7b352005966f94f9be9410571d0958788c3))

<a name="0.13.1"></a>
# 0.13.1 (2014-05-14)

## :bug: Bug Fixes

- **meta:** updates CHANGELOG with latest changes

<a name="0.13.0"></a>
# 0.13.0 (2014-05-14)

## :bug: Bug Fixes

- **markers**: handles properly declarations that spans on several lines ([349ada974e](https://github.com/abe33/atom-color-highlight/commit/349ada974e45919ec7426daa7f8940acc486961b), [#8](https://github.com/abe33/atom-color-highlight/issues/8))

<a name="0.12.0"></a>
# 0.12.0 (2014-04-25)

## :sparkles: Features

- **expressions**:
  - uses [pigments](https://github.com/abe33/pigments) module and removes previous color model
  - uses [project-palette-finder](https://atom.io/packages/project-palette-finder) color model if available

<a name="0.11.1"></a>
# 0.11.1 (2014-04-16)

## :sparkles: Features

- **docs**: updates the changelog

<a name="0.11.0"></a>
# 0.11.0 (2014-04-16)

## :sparkles: Features

- **dependencies**: updates oniguruma version from `1.x` to `2.x`

<a name="0.10.0"></a>
# 0.10.0 (2014-04-16)

## :sparkles: Features

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

## :sparkles: Features

- **expressions:**
  - adds support for hsv and hsva expression
  - adds support for `darken`, `lighten` and `transparentize` functions

## :bug: Bug Fixes

- **expressions:** previously hsl expressions was treated as in hsv color space

<a name="0.8.0"></a>
# 0.8.0 (2014-03-14)

## :bug: Bug Fixes

- **markers:** fixes invalid marker position on update after grammar change
  ([4f11759b](https://github.com/abe33/atom-color-highlight/commit/4f11759bad8e9bfa2a4b956ec56ab53928f802ee),
   [#2](https://github.com/abe33/atom-color-highlight/issues/2))
