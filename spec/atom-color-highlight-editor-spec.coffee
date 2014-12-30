
describe "AtomColorHighlightEditor", ->
  [workspaceElement, editor, editorElement, buffer, markers] = []

  beforeEach ->
    waitsForPromise -> atom.workspace.open('sample.js')

    waitsForPromise ->
      atom.packages.activatePackage('atom-color-highlight')

    runs ->
      workspaceElement = atom.views.getView(atom.workspace)
      jasmine.attachToDOM(workspaceElement)

      editor = atom.workspace.getActiveTextEditor()
      editorElement = atom.views.getView(editor)
      buffer = editor.getBuffer()

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
    waitsFor ->
      (markers = editorElement.shadowRoot.querySelectorAll('.region')).length > 0

  it 'retrieves the editor content', ->
    runs ->
      expect(markers.length).toEqual(9)

  describe 'when content is added to the editor', ->
    beforeEach ->
      editor.moveToBottom()
      editor.insertText(' red')

    it 'updates the markers in the view', ->
      waitsFor ->
        (markers = editorElement.shadowRoot.querySelectorAll('.region')).length > 9

      runs ->
        expect(markers.length).toEqual(10)

  describe 'when content is removed from the editor', ->
    beforeEach ->
      editor.setText('')

      waitsFor ->
        (markers = editorElement.shadowRoot.querySelectorAll('.region')).length isnt 9

    it 'removes all the markers in the view', ->
      expect(markers.length).toEqual(0)
