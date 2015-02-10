<a name="v3.0.8"></a>
# v3.0.8 (2015-02-10)

## :arrow_up: Dependencies Update

- Update pigments to version 3.2.0 ([99697994](https://github.com/abe33/atom-color-highlight/commit/99697994d62123e4cdaf66edfce85d6b17f869c9), [#75](https://github.com/abe33/atom-color-highlight/issues/75))

<a name="v3.0.7"></a>
# v3.0.7 (2015-02-09)

## :bug: Bug Fixes

- Fix calling method on undefined marker ([d58c511b](https://github.com/abe33/atom-color-highlight/commit/d58c511b89525a5d147a66f386e2cbc8c6fe3708), [#64](https://github.com/abe33/atom-color-highlight/issues/64))

<a name="v3.0.6"></a>
# v3.0.6 (2015-02-03)

- Upgrade pigments version. Includes fixes for [#74](https://github.com/abe33/atom-color-highlight/issues/74))

<a name="v3.0.5"></a>
# v3.0.5 (2015-01-16)

## :bug: Bug Fixes

- Fix deprecations on editor methods ([8386e01e](https://github.com/abe33/atom-color-highlight/commit/8386e01e72cee23be975d61984dcd23f3ec4b484))

<a name="v3.0.4"></a>
# v3.0.4 (2015-01-14)

## :bug: Bug Fixes

- Fix missing color search for restored text editors ([f189b73d](https://github.com/abe33/atom-color-highlight/commit/f189b73dc2a316e9754909ca1b9fd679146d90bb))
- Prevent errors in markers update when res is null ([cfe9dbfa](https://github.com/abe33/atom-color-highlight/commit/cfe9dbfa93e3760c28b313959b93e46ba724426e))
- Fix remaining deprecations ([36179390](https://github.com/abe33/atom-color-highlight/commit/36179390fe1e20d3118532cd2e93107f3a8c9c99))

<a name="v3.0.3"></a>
# v3.0.3 (2015-01-07)

## :bug: Bug Fixes

- Fix error raised when closing an editor ([f9914482](https://github.com/abe33/atom-color-highlight/commit/f991448225d1d1dd0c33efd9db8bce087d12b4b2))

<a name="v3.0.2"></a>
# v3.0.2 (2015-01-05)

## :bug: Bug Fixes

- Fix colors marker not rendered when editor is not active when opened ([5f291f66](https://github.com/abe33/atom-color-highlight/commit/5f291f6620273ad120cbcb265f6d9d8698b7a930))

<a name="v3.0.1"></a>
# v3.0.1 (2015-01-03)

- Add missing CHANGELOG entries for v3.0.0.

<a name="v3.0.0"></a>
# v3.0.0 (2015-01-03)

- The major changes in v3.0.0 concerns the view appended to the DOM. Now views are handled through custom elements instead of `space-pen` views.

<a name="v2.0.16"></a>
# v2.0.16 (2014-12-31)

## :bug: Bug Fixes

- Fix marker display issue when scrolling ([01aba50e](https://github.com/abe33/atom-color-highlight/commit/01aba50e0fd89262275895c4274f74115db27242))

<a name="v2.0.15"></a>
# v2.0.15 (2014-12-30)

## :bug: Bug Fixes

- Fix broken update check method ([f1f9c992](https://github.com/abe33/atom-color-highlight/commit/f1f9c992197a081cb7489fdef93293d4a8fc8df8))
- Fix remaining deprecations ([c186b932](https://github.com/abe33/atom-color-highlight/commit/c186b93207d5a516cd7d425e8abbf306385e3135))

<a name="v2.0.14"></a>
# v2.0.14 (2014-12-02)

## :bug: Bug Fixes

- Fix palette event deprecation ([7e905df5](https://github.com/abe33/atom-color-highlight/commit/7e905df5947a3278d9ad19e3f4b768d9f237f869))

<a name="v2.0.13"></a>
# v2.0.13 (2014-11-30)

## :bug: Bug Fixes

- Fix error raised on view destruction ([58ab0830](https://github.com/abe33/atom-color-highlight/commit/58ab0830f71f18d0c7946868eb8da2a1b5b82d4c), [#60](https://github.com/abe33/atom-color-highlight/issues/60))

<a name="v2.0.12"></a>
# v2.0.12 (2014-11-28)

## :bug: Bug Fixes

- Fix error raised when closing the last editor of a pane ([8ee359eb](https://github.com/abe33/atom-color-highlight/commit/8ee359ebb17b96cfae8dc2174d22f2d2c102198d))


<a name="v2.0.11"></a>
# v2.0.11 (2014-11-27)

## :bug: Bug Fixes

- Remove remaining logs ([73544811](https://github.com/abe33/atom-color-highlight/commit/73544811e7a4669d24ebafc359e9d7558936b4ab), [#58](https://github.com/abe33/atom-color-highlight/issues/58))


<a name="v2.0.10"></a>
# v2.0.10 (2014-11-26)

## :package: Dependencies

- Upgrade to pigments v3.0.4.

<a name="v2.0.9"></a>
# v2.0.9 (2014-11-26)

## :bug: Bug Fixes

- Prevent errors when accessing finder ([a0eba38d](https://github.com/abe33/atom-color-highlight/commit/a0eba38dd4592e35e5b63950c096ab9fb3ea1f67), [#57](https://github.com/abe33/atom-color-highlight/issues/57))

<a name="v2.0.8"></a>
# v2.0.8 (2014-11-25)

## :bug: Bug Fixes

- Change how finder package is required in models ([147647a2](https://github.com/abe33/atom-color-highlight/commit/147647a250a9aed6a39a04813af210dc73142199))

<a name="v2.0.7"></a>
# v2.0.7 (2014-11-25)

## :package: Dependencies

- Upgrade to pigments v3.0.3.

<a name="v2.0.6"></a>
# v2.0.6 (2014-11-17)

## :memo: Documentation

- Add a more detailed description of the `excludedGrammars` setting.

<a name="v2.0.5"></a>
# v2.0.5 (2014-11-14)

## :bug: Bug Fixes

- Rebuild markers on editor config changes ([845b8d65](https://github.com/abe33/atom-color-highlight/commit/845b8d6537538fc9036eb7141bcfa19b3e4d6e9a), [#32](https://github.com/abe33/atom-color-highlight/issues/32))
- Fix region styles when shadow DOM is enabled ([06c0f4e2](https://github.com/abe33/atom-color-highlight/commit/06c0f4e2aac3f466cecc56bc47ffa5929015568b))

<a name="v2.0.4"></a>
# v2.0.4 (2014-10-22)

## :bug: Bug Fixes

- Fix broken access to scope in latest Atom ([ffb4468d](https://github.com/abe33/atom-color-highlight/commit/ffb4468d196b93edf11cd0bcea21b26158aad1d0))

<a name="v2.0.3"></a>
# v2.0.3 (2014-10-15)

## :bug: Bug Fixes

- Fix issue with variable names in pigments ([51e4a719](https://github.com/abe33/atom-color-highlight/commit/51e4a7191cab8d897cd29367d9029dff252dc071))

<a name="v2.0.2"></a>
# v2.0.2 (2014-10-14)

## :bug: Bug Fixes

- Fix access to a removed private method ([f12d0a2f](https://github.com/abe33/atom-color-highlight/commit/f12d0a2f55eae586fec825966d3764f64783c14c))

<a name="v2.0.1"></a>
# v2.0.1 (2014-10-14)

## :bug: Bug Fixes

- Fix engine version ([52be0d14](https://github.com/abe33/atom-color-highlight/commit/52be0d145ee1ec610d5caaf365293bbf49942685))

<a name="v2.0.0"></a>
# v2.0.0 (2014-10-14)

## :sparkles: Features

- Add a setting to exclude specified grammar from highlighting ([724ff88a](https://github.com/abe33/atom-color-highlight/commit/724ff88aeb0d6d891798e92cec295c91140e8415))  <br>By setting a list of grammar scopes in the `excludedGrammars` setting,
  the corresponding files won’t display any color highlights.

## :bug: Bug Fixes

- Fix deprecations ([6a80af02](https://github.com/abe33/atom-color-highlight/commit/6a80af021e33dad4416854b183fa679a80f76ec7))
- Fix atom freeze when canceling big multiple selections ([10fb9bfa](https://github.com/abe33/atom-color-highlight/commit/10fb9bfa6a1bd95ba0a25c5a3b5124f1e39b7b3a))

<a name="v1.0.5"></a>
# v1.0.5 (2014-10-03)

## :bug: Bug Fixes

- Fix broken dot marker update since API changes ([a9b97049](https://github.com/abe33/atom-color-highlight/commit/a9b97049b8fdbd7ae85e093076178f07f590f25f))

<a name="v1.0.4"></a>
# v1.0.4 (2014-09-18)

## :bug: Bug Fixes

- Fix aliased color at n+2 not detected ([6f446e79](https://github.com/abe33/atom-color-highlight/commit/6f446e790ec083b87f4dde38035844ea0755304b))

## :racehorse: Performances

- Prevent works when no markers was found ([352c9cf1](https://github.com/abe33/atom-color-highlight/commit/352c9cf1fe248e9f69e1c8dd5def404094f72952))

<a name="v1.0.3"></a>
# v1.0.3 (2014-09-16)

## :bug: Bug Fixes

- Fix deprecated method calls on markers ([040475c8](https://github.com/abe33/atom-color-highlight/commit/040475c8019d5f19bacc236d5710224098581328))
- Fix deprecated method calls ([bfcc4a90](https://github.com/abe33/atom-color-highlight/commit/bfcc4a902e5d0c68a0a6aa74d17b7a308b817210))

<a name="v1.0.1"></a>
# v1.0.1 (2014-08-04)

## :bug: Bug Fixes

- Fix warning due to deprecated prefixed function ([49bd8c6e](https://github.com/abe33/atom-color-highlight/commit/49bd8c6e8f3e6fcb48ba4876d9c2a1b89a810e9c))

<a name="v1.0.0"></a>
# v1.0.0 (2014-08-04)

## :sparkles: Features

- Add support of pigments 2.0.0 and Atom 0.120.0 ([78d0db5f](https://github.com/abe33/atom-color-highlight/commit/78d0db5fc3665b26933340f89502b739de52b873))

## :bug: Bug Fixes

- Fix invalid layout when adding removing a color in a line ([a185707c](https://github.com/abe33/atom-color-highlight/commit/a185707c64a1c3a997785067a2fb6ea574c82ddb))

<a name="v0.19.4"></a>
# v0.19.4 (2014-07-30)

## :bug: Bug Fixes

- Fix missing match when a color is followed by a class selector ([8c482feb](https://github.com/abe33/atom-color-highlight/commit/8c482feb568db30829bffca96ace40bf7be0b386))

<a name="v0.19.3"></a>
# v0.19.3 (2014-07-21)

## :bug: Bug Fixes

- Fix invalid lighten/darken operation for less/sass ([abe33/pigments@8ac0214d](https://github.com/abe33/pigments/commit/8ac0214dd67ea34b77be21ce03440f9de914f3fe), [abe33/atom-color-highlight#26](https://github.com/abe33/atom-color-highlight/issues/26))
- Fix css color function raising exception when invalid ([abe33/pigments@a883ccad](https://github.com/abe33/pigments/commit/a883ccadb60a3498d01506ab821ed43e39992fe4), [abe33/atom-color-highlight#27](https://github.com/abe33/atom-color-highlight/issues/27))


<a name="v0.19.2"></a>
# v0.19.2 (2014-07-21)

## :bug: Bug Fixes

- Fix broken variable handling at n+1 ([abe33/pigments@f34be5b0](https://github.com/abe33/pigments/commit/f34be5b082ce60a11ad3f710604e410b60d5a4e8), [#23](https://github.com/abe33/atom-color-highlight/issues/23))

<a name="v0.19.1"></a>
# v0.19.1 (2014-07-20)

## :bug: Bug Fixes

- Fix creating markers for invalid colors ([dc204b98](https://github.com/abe33/atom-color-highlight/commit/dc204b981a42ee1404748c72f9e85227b4605275))

<a name="v0.19.0"></a>
# v0.19.0 (2014-07-20)

## :sparkles: Features

- Implement masking markers present in strings ([7691338b](https://github.com/abe33/atom-color-highlight/commit/7691338bfec09c4887927b0aefd04f4512c22a8c))
- Add support for variables in color functions ([abe33/pigments@ee67434a](https://github.com/abe33/pigments/commit/ee67434acc0ae8542e8cb02235247216561900fc))  
  <br>Includes:
  - Any parameter can now be a variable
  - Any missing variable will mark the color as invalid

<a name="v0.18.0"></a>
# v0.18.0 (2014-07-18)

## :bug: Bug Fixes

- Fix sass method parsed as css color function ([eced697f](https://github.com/abe33/atom-color-highlight/commit/eced697f8d3b8d6003e1959b7c306973d161aac7), [#21](https://github.com/abe33/atom-color-highlight/issues/21))

<a name="v0.17.0"></a>
# v0.17.0 (2014-07-16)

## :sparkles: Features

- Add support for css 4 `gray` functional notation. ([abe33/pigments@f8f0d212](https://github.com/abe33/pigments/commit/f8f0d21223c24b4724c8e0638b4f3b52126160b1))
- Add support for the `hwb` color model the corresponding css4 function. ([abe33/pigments@b64d9574](https://github.com/abe33/pigments/commit/b64d95749a348cb66e9434c5438eac6afbca0693), [abe33/atom-color-highlight#20](https://github.com/abe33/atom-color-highlight/issues/20))  

## :bug: Bug Fixes

- Fix z-index issues with popover lists ([ea13b1d1](https://github.com/abe33/atom-color-highlight/commit/ea13b1d1c473878708746ef020358914f7b5dd50), [#17](https://github.com/abe33/atom-color-highlight/issues/17))
- Fix missing getBufferRange method on dot markers ([4d25639b](https://github.com/abe33/atom-color-highlight/commit/4d25639b97439ab6ffc54113ab8c89fbb25c967b), [#19](https://github.com/abe33/atom-color-highlight/issues/19))

<a name="v0.16.0"></a>
# v0.16.0 (2014-07-11)

## :sparkles: Features

- Implement masking markers present in comments ([cb4d5529](https://github.com/abe33/atom-color-highlight/commit/cb4d5529231cdfdbb6a4d9645c27b394db111587), [#16](https://github.com/abe33/atom-color-highlight/issues/16))
- Implement dot markers on end of lines ([98d7e33d](https://github.com/abe33/atom-color-highlight/commit/98d7e33d531b0fc2a6e20bb9f8d54bc1be78d796), [#11](https://github.com/abe33/atom-color-highlight/issues/11))

<a name="v0.15.0"></a>
# v0.15.0 (2014-07-10)

## :sparkles: Features

- Add Travis CI setup ([38bbaf09](https://github.com/abe33/atom-color-highlight/commit/38bbaf096062558fe6848e945e73fb4c0ecfb5e1))
- Implement highlight update on palette refresh ([a0aa45f6](https://github.com/abe33/atom-color-highlight/commit/a0aa45f6c2f7ee4220e3dd1e64b3ade40bece018))

## :bug: Bug Fixes

- Fix views and models access by editors on react ([3f0c77eb](https://github.com/abe33/atom-color-highlight/commit/3f0c77eb29e418bf257f257bbab2eb65d3791696))

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
