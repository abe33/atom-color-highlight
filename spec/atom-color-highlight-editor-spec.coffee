{WorkspaceView} = require 'atom'

editorView = null

describe "AtomColorHighlightEditor", ->
  beforeEach ->
    waitsForPromise ->
      atom.workspaceView = new WorkspaceView
      atom.workspaceView.open('sample.js')

    runs ->
      atom.workspaceView.attachToDom()
      editorView = atom.workspaceView.getActiveView()
      editorView.setText("""
      color = #f0f

      light_color = lighten(color, 50%)

      other_color = color - rgba(0,0,0,0.5)
      """)

    waitsForPromise ->
      atom.packages.activatePackage('atom-color-highlight')

  describe 'once the package is toggled', ->
    it 'should have retrieved the editor content', ->
      container = null
      waitsFor ->
        (container = atom.workspaceView.find('.marker')).length > 0

      runs ->
        expect(container.length).toEqual(4)
