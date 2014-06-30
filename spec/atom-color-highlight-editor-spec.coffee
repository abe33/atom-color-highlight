{WorkspaceView} = require 'atom'

editorView = null
editor = null
buffer = null
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

      light_color = lighten(color, 50%)

      other_color = color - rgba(0,0,0,0.5)
      """)

    waitsForPromise ->
      atom.packages.activatePackage('atom-color-highlight')

  describe 'once the package is toggled', ->
    it 'retrieves the editor content', ->
      markers = null
      waitsFor ->
        (markers = atom.workspaceView.find('.marker')).length > 0

      runs ->
        expect(markers.length).toEqual(4)

    describe 'modifying the buffer', ->
      beforeEach ->
        editor.setTextInBufferRange [[0,9], [0,12]], '0ff'

      it 'updates only the concerned markers', ->
        console.log buffer.getText()
