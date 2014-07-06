{WorkspaceView} = require 'atom'
AtomColorHighlightModel = require '../lib/atom-color-highlight-model'

describe 'AtomColorHighlightModel', ->
  [editorView, editor, buffer, model, Range] = []

  beforeEach ->
    waitsForPromise ->
      atom.workspaceView = new WorkspaceView
      atom.workspaceView.open('sample.js')

    runs ->
      atom.workspaceView.attachToDom()
      editorView = atom.workspaceView.getActiveView()
      editor = editorView.getEditor()
      buffer = editor.getBuffer()
      Range = buffer.constructor.Range

      editorView.setText("""
      color = #f0f
      other_color = #ff0

      light_color = lighten(color, 50%)

      transparent_color = color - rgba(0,0,0,0.5)
      """)

      model = new AtomColorHighlightModel editor, buffer

  describe 'once initialized', ->
    [markersCreated, markersDestroyed] = []

    beforeEach ->
      markersCreated = jasmine.createSpy('markersCreated')
      markersDestroyed = jasmine.createSpy('markersDestroyed')
      model.once 'markers:created', markersCreated
      model.once 'markers:destroyed', markersDestroyed
      waitsForPromise -> model.init()

    it 'has stored variables present in the files', ->
      expect(Object.keys(model.variables)).toEqual([
        'color'
        'other_color'
        'light_color'
      ])

    it 'has stored the markers for colors', ->
      expect(model.markers.length).toEqual(5)

    it 'dispatches a markers:created event', ->
      expect(markersCreated).toHaveBeenCalled()

    it 'does not dispatch a markers:destroyed event', ->
      expect(markersDestroyed).not.toHaveBeenCalled()

    describe 'modifying the buffer', ->
      beforeEach ->
        runs ->
          markersCreated = jasmine.createSpy('markersCreated')
          markersDestroyed = jasmine.createSpy('markersDestroyed')
          model.once 'markers:created', markersCreated
          model.once 'markers:destroyed', markersDestroyed

          editor.setTextInBufferRange [[0,9], [0,12]], '0ff'
          buffer.emit('contents-modified')

        waitsFor -> markersCreated.callCount > 0

      it 'destroys all markers concerned by the change', ->
        expect(markersDestroyed.argsForCall[0][0].length).toEqual(3)

      it 'creates new markers corresponding to the changes', ->
        expect(markersCreated.argsForCall[0][0].length).toEqual(3)

  describe '::expandRangeToCompleteLines', ->
    it 'expands a given to match full lines', ->
      expect(model.expandRangeToCompleteLines [[1,4], [3,5]]).toEqual([
        [1,0], [3,Infinity]
      ])

  describe '::packChanges', ->
    describe 'with a change inside another', ->
      it 'removes the included ranges from the changes list', ->
        changes = [
          {
            oldRange: Range.fromObject [[0,0], [2,20]]
            newRange: Range.fromObject [[0,0], [2,20]]
          }
          {
            oldRange: Range.fromObject [[0,5], [1,4]]
            newRange: Range.fromObject [[0,5], [1,4]]
          }
        ]

        packedChanges = model.packChanges(changes)

        expect(packedChanges).toBeDefined()
        expect(packedChanges.oldRanges.length).toEqual(1)
        expect(packedChanges.newRanges.length).toEqual(1)

        expect(packedChanges.oldRanges[0].start.row).toEqual(0)
        expect(packedChanges.oldRanges[0].start.column).toEqual(0)
        expect(packedChanges.oldRanges[0].end.row).toEqual(2)
        expect(packedChanges.oldRanges[0].end.column).toEqual(20)

        expect(packedChanges.newRanges[0].start.row).toEqual(0)
        expect(packedChanges.newRanges[0].start.column).toEqual(0)
        expect(packedChanges.newRanges[0].end.row).toEqual(2)
        expect(packedChanges.newRanges[0].end.column).toEqual(20)

      describe 'with a change intersecting with another', ->
        it 'merges the two ranges in one', ->
          changes = [
            {
              oldRange: Range.fromObject [[0,0], [1,10]]
              newRange: Range.fromObject [[0,0], [1,10]]
            }
            {
              oldRange: Range.fromObject [[1,10], [2,20]]
              newRange: Range.fromObject [[1,10], [2,20]]
            }
          ]

          packedChanges = model.packChanges(changes)

          expect(packedChanges).toBeDefined()
          expect(packedChanges.oldRanges.length).toEqual(1)
          expect(packedChanges.newRanges.length).toEqual(1)

          expect(packedChanges.oldRanges[0].start.row).toEqual(0)
          expect(packedChanges.oldRanges[0].start.column).toEqual(0)
          expect(packedChanges.oldRanges[0].end.row).toEqual(2)
          expect(packedChanges.oldRanges[0].end.column).toEqual(20)

          expect(packedChanges.newRanges[0].start.row).toEqual(0)
          expect(packedChanges.newRanges[0].start.column).toEqual(0)
          expect(packedChanges.newRanges[0].end.row).toEqual(2)
          expect(packedChanges.newRanges[0].end.column).toEqual(20)

      describe 'two changes that do not intersects', ->
        it 'leaves the two changes unchanged', ->
          changes = [
            {
              oldRange: Range.fromObject [[0,0], [1,4]]
              newRange: Range.fromObject [[0,0], [1,4]]
            }
            {
              oldRange: Range.fromObject [[1,10], [2,20]]
              newRange: Range.fromObject [[1,10], [2,20]]
            }
          ]

          packedChanges = model.packChanges(changes)

          expect(packedChanges).toBeDefined()
          expect(packedChanges.oldRanges.length).toEqual(2)
          expect(packedChanges.newRanges.length).toEqual(2)

          expect(packedChanges.oldRanges[0].start.row).toEqual(0)
          expect(packedChanges.oldRanges[0].start.column).toEqual(0)
          expect(packedChanges.oldRanges[0].end.row).toEqual(1)
          expect(packedChanges.oldRanges[0].end.column).toEqual(4)

          expect(packedChanges.oldRanges[1].start.row).toEqual(1)
          expect(packedChanges.oldRanges[1].start.column).toEqual(10)
          expect(packedChanges.oldRanges[1].end.row).toEqual(2)
          expect(packedChanges.oldRanges[1].end.column).toEqual(20)

          expect(packedChanges.newRanges[0].start.row).toEqual(0)
          expect(packedChanges.newRanges[0].start.column).toEqual(0)
          expect(packedChanges.newRanges[0].end.row).toEqual(1)
          expect(packedChanges.newRanges[0].end.column).toEqual(4)

          expect(packedChanges.newRanges[1].start.row).toEqual(1)
          expect(packedChanges.newRanges[1].start.column).toEqual(10)
          expect(packedChanges.newRanges[1].end.row).toEqual(2)
          expect(packedChanges.newRanges[1].end.column).toEqual(20)
