{WorkspaceView} = require 'atom'

editorView = null
editor = null
buffer = null
highlight = null
atomPackage = null

describe "AtomColorHighlightEditor", ->
  beforeEach ->
    waitsForPromise ->
      atom.workspaceView = new WorkspaceView
      atom.workspaceView.open('sample.js')

    runs ->
      atom.workspaceView.attachToDom()
      editorView = atom.workspaceView.getActiveView()
      editor = editorView.getEditor()
      buffer = editor.getBuffer()

      editorView.setText("""
      $color: #f0f
      $other_color: #ff0

      $light_color: lighten($color, 50%)

      $transparent_color: $color - rgba(0,0,0,0.5)

      $color_red: #D11A0A
      $color_red_light: lighten($color_red, 30%)
      $color_red_dark: darken($color_red, 10%)
      $color_red_darker: darken($color_red, 20%)
      """)

    waitsForPromise ->
      atom.packages.activatePackage('atom-color-highlight')

  describe 'once the package is toggled', ->
    it 'retrieves the editor content', ->
      markers = null
      waitsFor ->
        (markers = atom.workspaceView.find('.marker')).length > 0

      runs ->
        expect(markers.length).toEqual(9)
