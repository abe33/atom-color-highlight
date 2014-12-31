
describe "AtomColorHighlightEditor", ->
  [workspaceElement, editor, editorElement, buffer, markers, atomColorHighlight, model] = []

  beforeEach ->
    atom.config.set 'editor.fontSize', 10
    atom.config.set 'editor.lineHeight', 1

    waitsForPromise -> atom.workspace.open('sample.js')

    waitsForPromise ->
      atom.packages.activatePackage('atom-color-highlight').then (pkg) ->
        atomColorHighlight = pkg.mainModule

    runs ->
      workspaceElement = atom.views.getView(atom.workspace)
      jasmine.attachToDOM(workspaceElement)

      editor = atom.workspace.getActiveTextEditor()
      editorElement = atom.views.getView(editor)
      buffer = editor.getBuffer()
      model = atomColorHighlight.modelForEditor(editor)

      editor.setText("""
      $color: #f0f
      $other_color: #ff0

      $light_color: lighten($color, 50%)

      $transparent_color: $color - rgba(0,0,0,0.5)

      $color_red: #D11A0A
      $color_red_light: lighten($color_red, 30%)
      $color_red_dark: darken($color_red, 10%)
      $color_red_darker: darken($color_red, 20%)
      """)

    waitsFor -> not model.dirty

    runs ->
      markers = editorElement.shadowRoot.querySelectorAll('.region')

  it 'retrieves the editor content', ->
    expect(markers.length).toEqual(9)

  it 'positions the regions properly', ->
    expect(markers[0].offsetTop).toEqual(0)
    expect(markers[1].offsetTop).toEqual(10)

  describe 'when content is added to the editor', ->
    beforeEach ->
      editor.moveToBottom()
      editor.insertText(' red')

      waitsFor -> not model.dirty

    it 'updates the markers in the view', ->
      markers = editorElement.shadowRoot.querySelectorAll('.region')
      expect(markers.length).toEqual(10)

  xdescribe 'when core:backspace is triggered', ->
    beforeEach ->
      editor.setCursorBufferPosition [5,0]
      atom.commands.dispatch(editorElement, 'core:backspace')

  describe 'when content is removed from the editor', ->
    beforeEach ->
      editor.setText('')

      waitsFor -> not model.dirty

    it 'removes all the markers in the view', ->
      markers = editorElement.shadowRoot.querySelectorAll('.region')
      expect(markers.length).toEqual(0)
