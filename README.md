# Atom Color Highlight

Highlights colors in files.

**IMPORTANT: If you encouter an update issue within atom when updating from `0.8.x` or `0.9.x` version to `0.10.x` or `0.11.x`, try uninstalling the package through the Atom Settings Panel and reinstalling again. **

![AtomColorHighlight Screenshot](https://raw.github.com/abe33/atom-color-highlight/master/atom-color-highlight.jpg)

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
Color = require(atomColorHighlight.path + '/lib/color-model')

Color.addExpression 'oniguruma regexp', (color, expression) ->
  # modify color using data extracted from expression
```

The first argument is a string that match the new expression using
[Oniguruma](https://github.com/atom/node-oniguruma) regular expressions.
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
Color.addExpression "#([\\da-fA-F]{6})(?![\\da-fA-F])", (color, expression) ->
  [m, hexa] = @onigRegExp.search(expression)

  color.hex = hexa.match
```
