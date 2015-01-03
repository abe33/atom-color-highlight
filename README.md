# Atom Color Highlight [![Build Status](https://travis-ci.org/abe33/atom-color-highlight.svg?branch=master)](https://travis-ci.org/abe33/atom-color-highlight)

Highlights colors in files.

![AtomColorHighlight Screenshot](https://raw.github.com/abe33/atom-color-highlight/master/atom-color-highlight-variables.gif)

![AtomColorHighlight Screenshot](https://raw.github.com/abe33/atom-color-highlight/master/atom-color-highlight.jpg)

### Project Palette Support

If you have the [project-palette-finder package](https://atom.io/packages/project-palette-finder) installed, the package will automatically benefit from the palette definitions:

![AtomColorHighlight And Project Palette Screenshot](https://raw.github.com/abe33/atom-color-highlight/master/atom-color-highlight-palette.jpg)

### API

This package provides some API so that you can access the models it creates for the text editors:

#### Observing Models Creation

```coffeescript
atom.packages.activatePackage('atom-color-highlight').then (pkg) ->
  atomColorHighlight = pkg.mainModule

  atomColorHighlight.observeColorHighlightModels (model) ->
    # Model is an instance of AtomColorHighlightModel
```

#### Retrieving Models For Text Editors

```coffeescript
atom.packages.activatePackage('atom-color-highlight').then (pkg) ->
  atomColorHighlight = pkg.mainModule

  model = atomColorHighlight.modelForEditor(editor)
```

#### Listening To A Model's Markers Update

```coffeescript
model.onDidUpdateMarkers (markers) ->
  # Do something with markers
```

The `markers` array contains the display buffer markers for all the colors found in the corresponding text editor. Those markers contains extra properties with color data:

* `marker.bufferMarker.properties.color`: The color `String` that was matched by the model.
* `marker.bufferMarker.properties.cssColor`: The CSS representation of the color as a `String`.
* `marker.bufferMarker.properties.textColor`: The text color, based on the original color luminance, computed beforehand.

### Modifying Markers Styles

To target the classical markers, use the following rule:

```less
atom-text-edidor, atom-text-editor::shadow {
  atom-color-highlight color-marker .region {
    // ...
  }
}
```

And to target the dot marker at end of lines, use the following rule:

```less
atom-text-edidor, atom-text-editor::shadow {
  atom-color-highlight dot-color-marker {
    // ...
  }
}
```

### Extending Color Parsing

You can register a new color expression using the `Color.addExpression` method.

```coffeescript
atom.packages.activatePackage('atom-color-highlight').then (pkg) ->
  atomColorHighlight = pkg.mainModule
  {Color} = atomColorHighlight

  Color.addExpression 'name', 'regexp', (color, expression, fileVariables) ->
    # modify color using data extracted from expression
```

The first argument is a string that match the new expression using regular expressions.
This string will be used to match the expression both when scanning the
buffer and when creating a `Color` object for the various matches.

Note that the regular expression source will be concatened with the other
expressions to create the `RegExp` used on the buffer.
In that regards, selectors such `^` and `$` should be avoided at all cost.

The second argument is the function called by the `Color` class when the
current expression match your regexp. It'll be called with the `Color` instance
to modify, the matching expression as a string and an object containing the variables found in the file (can be colors or any other values).

For instance, the CSS hexadecimal RGB notation is defined as follow:

```coffeescript
Color.addExpression 'css_hexa_6', "#([\\da-fA-F]{6})(?![\\da-fA-F])", (color, expression, fileVariables) ->
  [m, hexa] = @onigRegExp.search(expression)

  color.hex = hexa.match
```
