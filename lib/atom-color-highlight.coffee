AtomColorHighlightEditor = require './atom-color-highlight-editor'

module.exports =
  activate: (state) ->
    atom.workspaceView.eachEditorView (editor) ->
      new AtomColorHighlightEditor(editor)

  serialize: -> {}
