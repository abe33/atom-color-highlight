
describe "AtomColorHighlight", ->
  [workspaceElement, editor, editorElement, buffer, markers, atomColorHighlight, model, charWidth] = []

  beforeEach ->
    atom.config.set 'editor.fontSize', 10
    atom.config.set 'editor.lineHeight', 1

    waitsForPromise -> atom.packages.activatePackage('language-sass')
    waitsForPromise -> atom.workspace.open('sample.sass')

    waitsForPromise ->
      atom.packages.activatePackage('atom-color-highlight').then (pkg) ->
        atomColorHighlight = pkg.mainModule

    runs ->
      workspaceElement = atom.views.getView(atom.workspace)
      jasmine.attachToDOM(workspaceElement)

      styleNode = document.createElement('style')
      styleNode.textContent = """
        atom-text-editor atom-color-highlight .region,
        atom-text-editor::shadow atom-color-highlight .region {
          margin-left: 0 !important;
        }

        atom-text-editor atom-color-highlight dot-color-marker,
        atom-text-editor::shadow atom-color-highlight dot-color-marker {
          margin-top: 0 !important;
        }
      """

      jasmine.attachToDOM(styleNode)

      editor = atom.workspace.getActiveTextEditor()
      editorElement = atom.views.getView(editor)
      buffer = editor.getBuffer()
      model = atomColorHighlight.modelForEditor(editor)
      charWidth = editor.getDefaultCharWidth()

      editor.setText("""
      $color: #f0f
      $other_color: '#ff0'

      // $light_color: lighten($color, 50%)

      $transparent_color: $color - rgba(0,0,0,0.5)

      $color_red: #D11A0A
      $color_red_light: lighten($color_red, 30%)
      $color_red_dark: darken($color_red, 10%)
      $color_red_darker: darken($color_red, 20%)
      """)

      editor.getBuffer().emitter.emit('did-stop-changing')

    waitsFor -> not model.dirty

    runs ->
      markers = editorElement.shadowRoot.querySelectorAll('.region')

  it 'retrieves the editor content', ->
    expect(markers.length).toEqual(9)

  it 'positions the regions properly', ->
    expect(markers[0].offsetTop).toEqual(0)
    expect(markers[0].offsetLeft).toEqual(8 * charWidth)

    expect(markers[1].offsetTop).toEqual(10)
    expect(markers[1].offsetLeft).toEqual(15 * charWidth)

    expect(markers[2].offsetTop).toEqual(30)
    expect(markers[2].offsetLeft).toEqual(17 * charWidth)

    expect(markers[3].offsetTop).toEqual(50)
    expect(markers[3].offsetLeft).toEqual(20 * charWidth)

    expect(markers[4].offsetTop).toEqual(50)
    expect(markers[4].offsetLeft).toEqual(29 * charWidth)

    expect(markers[5].offsetTop).toEqual(70)
    expect(markers[5].offsetLeft).toEqual(12 * charWidth)

  describe 'when content is added to the editor', ->
    beforeEach ->
      editor.moveToBottom()
      editor.insertText(' red')
      editor.getBuffer().emitter.emit('did-stop-changing')

      waitsFor -> not model.dirty

    it 'updates the markers in the view', ->
      markers = editorElement.shadowRoot.querySelectorAll('.region')
      expect(markers.length).toEqual(10)

  describe 'when core:backspace is triggered', ->
    beforeEach ->
      editor.setCursorBufferPosition [5,0]
      atom.commands.dispatch(editorElement, 'core:backspace')
      editor.getBuffer().emitter.emit('did-stop-changing')

      waitsFor -> not model.dirty

    it 'adjusts the position of the markers in the view', ->
      markers = editorElement.shadowRoot.querySelectorAll('.region')

      expect(markers[4].offsetTop).toEqual(40)
      expect(markers[4].offsetLeft).toEqual(29 * charWidth)

      expect(markers[5].offsetTop).toEqual(60)
      expect(markers[5].offsetLeft).toEqual(12 * charWidth)

  describe 'when content is removed from the editor', ->
    beforeEach ->
      editor.setText('')
      editor.getBuffer().emitter.emit('did-stop-changing')

      waitsFor -> not model.dirty

    it 'removes all the markers in the view', ->
      markers = editorElement.shadowRoot.querySelectorAll('.region')
      expect(markers.length).toEqual(0)

  describe 'when the markers at end of line setting is enabled', ->
    beforeEach ->
      atom.config.set 'atom-color-highlight.markersAtEndOfLine', true
      markers = editorElement.shadowRoot.querySelectorAll('dot-color-marker')

    it 'replaces the markers with dot markers', ->
      expect(markers.length).toEqual(9)

    it 'positions the dot markers at the end of line', ->
      spacing = atom.config.get('atom-color-highlight.dotMarkersSpacing')
      size = atom.config.get('atom-color-highlight.dotMarkersSize')

      expect(markers[0].offsetLeft).toEqual(12 * charWidth + spacing)
      expect(markers[0].offsetTop).toEqual(0)

      expect(markers[1].offsetLeft).toEqual(20 * charWidth + spacing)
      expect(markers[1].offsetTop).toEqual(10)

      expect(markers[2].offsetLeft).toEqual(37 * charWidth + spacing)
      expect(markers[2].offsetTop).toEqual(30)

      expect(markers[3].offsetLeft).toEqual(44 * charWidth + spacing)
      expect(markers[3].offsetTop).toEqual(50)

      expect(markers[4].offsetLeft).toEqual(44 * charWidth + spacing * 2 + size)
      expect(markers[4].offsetTop).toEqual(50)

      expect(markers[5].offsetLeft).toEqual(19 * charWidth + spacing)
      expect(markers[5].offsetTop).toEqual(70)

  describe 'when hide markers in comments is enabled', ->
    beforeEach ->
      atom.config.set 'atom-color-highlight.hideMarkersInComments', true

    it 'hides the corresponding markers', ->
      markers = editorElement.shadowRoot.querySelectorAll('color-marker:not([style*="display: none"])')
      expect(markers.length).toEqual(8)

  describe 'when hide markers in strings is enabled', ->
    beforeEach ->
      atom.config.set 'atom-color-highlight.hideMarkersInStrings', true

    it 'hides the corresponding markers', ->
      markers = editorElement.shadowRoot.querySelectorAll('color-marker:not([style*="display: none"])')
      expect(markers.length).toEqual(8)

  describe 'when an exclusion scope is defined in settings', ->
    beforeEach ->
      atom.config.set 'atom-color-highlight.excludedGrammars', ['source.css']

      waitsForPromise -> atom.packages.activatePackage('language-css')
      waitsForPromise -> atom.workspace.open('source.css')

      runs ->
        editor = atom.workspace.getActiveTextEditor()
        editorElement = atom.views.getView(editor)
        model = atomColorHighlight.modelForEditor(editor)

    it 'does not create a model for the editor', ->
      expect(model).toBeUndefined()

    it 'does not render markers in the editor', ->
      expect(editorElement.shadowRoot.querySelectorAll('color-marker').length).toEqual(0)

  describe 'when the package is deactivated', ->
    beforeEach ->
      atom.packages.deactivatePackage('atom-color-highlight')

    it 'removes the view from the text editor', ->
      expect(editorElement.shadowRoot.querySelector('atom-color-highlight')).not.toExist()
