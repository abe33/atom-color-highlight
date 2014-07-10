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
      color = #f0f
      other_color = #ff0

      light_color = lighten(color, 50%)

      transparent_color = color - rgba(0,0,0,0.5)
      """)

    waitsForPromise ->
      atom.packages.activatePackage('atom-color-highlight')

    runs ->
      atomPackage = require atom.packages.getLoadedPackage('atom-color-highlight').path
      highlight = atomPackage.editors[editor.id]

  describe 'once the package is toggled', ->
    it 'retrieves the editor content', ->
      markers = null
      waitsFor ->
        (markers = atom.workspaceView.find('.marker')).length > 0

      runs ->
        expect(markers.length).toEqual(5)
