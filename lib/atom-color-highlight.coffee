{EditorView} = require 'atom'
{Emitter} = require 'emissary'
AtomColorHighlightEditor = null

class AtomColorHighlight
  Emitter.includeInto(this)

  configDefaults:
    markersAtEndOfLine: false
    hideMarkersInComments: false
    hideMarkersInStrings: false
    dotMarkersSize: 16
    dotMarkersSpacing: 4

  editors: {}
  activate: (state) ->
    atom.workspaceView.eachEditorView (editor) =>
      AtomColorHighlightEditor ||= require './atom-color-highlight-editor'

      colorEditor = new AtomColorHighlightEditor(editor)

      @editors[editor.editor.id] = colorEditor
      @emit 'color-highlight:editor-created', colorEditor

  eachColorHighlightEditor: (callback) ->
    callback?(editor) for id,editor of @editors if callback?
    @on 'color-highlight:editor-created', callback

  viewForEditorView: (editorView) ->
    @viewForEditor(editorView.getEditor()) if editorView?.hasClass('editor')

  modelForEditorView: (editorView) ->
    @modelForEditor(editorView.getEditor()) if editorView?.hasClass('editor')

  modelForEditor: (editor) -> @editors[editor.id]?.getActiveModel()
  viewForEditor: (editor) -> @editors[editor.id]?.getactiveView()

  deactivate: ->
    for id,editor of @editors
      @emit 'color-highlight:editor-will-be-destroyed', editor
      editor.destroy()

module.exports = new AtomColorHighlight
