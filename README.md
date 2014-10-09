# Atom Color Highlight [![Build Status](https://travis-ci.org/abe33/atom-color-highlight.svg?branch=master)](https://travis-ci.org/abe33/atom-color-highlight)

Highlights colors in files.

![AtomColorHighlight Screenshot](https://raw.github.com/abe33/atom-color-highlight/master/atom-color-highlight-variables.gif)

![AtomColorHighlight Screenshot](https://raw.github.com/abe33/atom-color-highlight/master/atom-color-highlight.jpg)

### Project Palette Support

If you have the [project-palette-finder package](https://atom.io/packages/project-palette-finder) installed, the package will automatically benefit from the palette definitions:

![AtomColorHighlight And Project Palette Screenshot](https://raw.github.com/abe33/atom-color-highlight/master/atom-color-highlight-palette.jpg)

### Extending AtomColorHighlight

#### Accessing the package

Atom currently doesn't provides a simple way to access installed package,
however, the `PackageManager`, accessible through the `atom.packages` property,
provides the `resolvePackagePath` method that return the absolute path
of a specified package.

Knowing that, you can, either in a package on in your atom init script,
require the package using:

```coffeescript
atomColorHighlight = atom.packages.getLoadedPackage 'atom-color-highlight'
atomColorHighlight = require(atomColorHighlight.path)
```

#### Adding new color

You can register a new color expression using the `Color.addExpression` method.

```coffeescript
atomColorHighlight = atom.packages.getLoadedPackage 'atom-color-highlight'
Color = require(atomColorHighlight.path + '/lib/atom-color-highlight-model').Color

Color.addExpression 'name', 'regexp', (color, expression) ->
  # modify color using data extracted from expression
```

The first argument is a string that match the new expression using regular expressions.
This string will be used to match the expression both when scanning the
buffer and when creating a `Color` object for the various matches.

Note that the regular expression source will be concatened with the other
expressions to create the `OnigRegExp` used on the buffer.
In that regards, selectors such `^` and `$` should be avoided at all cost.

The second argument is the function called by the `Color` class when the
current expression match your regexp. It'll be called with the `Color` instance
to modify and the matching expression.

For instance, the CSS hexadecimal RGB notation is defined as follow:

```coffeescript
Color.addExpression 'css_hexa_6', "#([\\da-fA-F]{6})(?![\\da-fA-F])", (color, expression) ->
  [m, hexa] = @onigRegExp.search(expression)

  color.hex = hexa.match
```
