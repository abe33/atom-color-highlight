{EditorView} = require 'atom'
{Emitter} = require 'emissary'

AtomColorHighlightEditor = require './atom-color-highlight-editor'

class AtomColorHighlight
  Emitter.includeInto(this)

  editors: {}
  activate: (state) ->
    atom.workspaceView.eachEditorView (editor) =>
      return if editor.hasClass 'mini'
      colorEditor = new AtomColorHighlightEditor(editor)

      @editors[editor.editor.id] = colorEditor
      @emit 'color-highlight:editor-created', colorEditor

  eachColorHighlightEditor: (callback) ->
    callback?(editor) for id,editor of @editors if callback?
    @on 'color-highlight:editor-created', callback

  viewForEditorView: (editorView) ->
    @viewForEditor(editorView.getEditor()) if editorView instanceof EditorView

  modelForEditorView: (editorView) ->
    @modelForEditor(editorView.getEditor()) if editorView instanceof EditorView

  modelForEditor: (editor) -> @editors[editor.id]?.getActiveModel()
  viewForEditor: (editor) -> @editors[editor.id]?.getactiveView()

  deactivate: ->
    for id,editor of @editors
      @emit 'color-highlight:editor-will-be-destroyed', editor
      editor.destroy()

module.exports = new AtomColorHighlight
