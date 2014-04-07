{Emmiter} = require 'emissary'
AtomColorHighlightEditor = require './atom-color-highlight-editor'

class AtomColorHighlight
  Emmiter.includeInto(this)

  editors: {}
  activate: (state) ->
    atom.workspaceView.eachEditorView (editor) =>
      colorEditor = new AtomColorHighlightEditor(editor)

      @editors[editor.editor.id] = colorEditor
      @emit 'color-highlight:editor-created', colorEditor

  viewForEditorView: (editorView) ->
    @viewForEditor(editorView.getEditor())

  modelForEditorView: (editorView) ->
    @modelForEditor(editorView.getEditor())

  modelForEditor: (editor) -> @editors[editor.id]?.getActiveModel()
  viewForEditor: (editor) -> @editors[editor.id]?.getactiveView()

  deactivate: ->
    for id,editor of @editors
      @emit 'color-highlight:editor-will-be-destroyed', editor
      editor.destroy()

module.exports =
