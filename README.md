# Atom Color Highlight

Highlights colors in files.

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
atomColorHighlightPath = atom.packages.resolvePackagePath 'atom-color-highlight'
atomColorHighlight = require(atomColorHighlightPath)
```

#### Adding new color

You can register a new color expression using the `Color.addExpression` method.

```coffeescript
atomColorHighlightPath = atom.packages.resolvePackagePath 'atom-color-highlight'
Color = require(atomColorHighlightPath + '/lib/color-model')

Color.addExpression /regexp/, (color, expression) ->
  # modify color using data extracted from expression
```

The first argument is a regular expression that match the new expression.
This `RegExp` will be used to match the expression both when scanning the
buffer and when creating a `Color` object for the various matches.

Note that the regular expression source will be concatened with the other
expressions to create the `RegExp` used the buffer. In that regards, selectors
such `^` and `$` should be avoided at all cost.

The second argument is the function called by the `Color` class when the
current expression match your regexp. It'll be called with the `Color' instance
to modify and the matching expression.

For instance, the CSS hexadecimal RGB notation is defined as follow:

```coffeescript
Color.addExpression /#([\da-fA-F]{6})(?!\d)/, (color, expression) ->
  [m, hexa] = @regexp.exec(expression)

  color.hex = hexa.replace('#', '')
```
