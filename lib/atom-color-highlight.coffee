{EditorView} = require 'atom'
{Emitter} = require 'emissary'
AtomColorHighlightEditor = null

class AtomColorHighlight
  Emitter.includeInto(this)

  config:
    markersAtEndOfLine:
      type: 'boolean'
      default: false
    hideMarkersInComments:
      type: 'boolean'
      default: false
    hideMarkersInStrings:
      type: 'boolean'
      default: false
    dotMarkersSize:
      type: 'number'
      default: 16
      min: 2
    dotMarkersSpacing:
      type: 'number'
      default: 4
      min: 0

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
