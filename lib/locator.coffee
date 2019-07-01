{ Disposable } = require 'atom'
path = require 'path'
cp = require 'child_process'

module.exports =
class Locator extends Disposable
  constructor: (latex) ->
    @latex = latex

  synctex: ->
    editor = atom.workspace.getActivePaneItem()
    currentPath = editor?.buffer.file?.path
    currentPosition = editor?.cursors[0].getBufferPosition()

    return if !currentPath? or !@latex.manager.isTexFile(currentPath)

    cmd = """synctex view -i \"#{currentPosition.row + 1}:\
             #{currentPosition.column + 1}:\
             #{currentPath}\" -o \"\
             #{@latex.manager.findPDF()}\""""
    cp.exec(cmd, {cwd: path.dirname @latex.mainFile}, (err, stdout, stderr) =>
      if (err)
        @latex.logger.processError(
          """Failed SyncTeX (code #{err.code}).""", err.message
        )
        return
      record = @parseResult(stdout)
      if Object.keys(record).length = 0
        @latex.logger.processError(
          'Failed SyncTeX', "Unable to parse output:\n\n\n #{stdout}"
        )
        return
      @latex.viewer.synctex(record)
    )

  parseResult: (out) ->
    record = {}
    started = false
    for line in out.split('\n')
      if line.indexOf('SyncTeX result begin') > -1
        started = true
        continue
      break if line.indexOf('SyncTeX result end') > -1
      continue if not started
      pos = line.indexOf(':')
      continue if pos < 0
      key = line.substr(0, pos).toLowerCase()
      continue if key of record
      record[line.substr(0, pos).toLowerCase()] = line.substr(pos + 1)
    return record

  locate: (data) ->
    cmd = """synctex edit -o \"#{data.page}:#{data.pos[0]}:#{data.pos[1]}:\
             #{@latex.manager.findPDF()}\""""
    cp.exec(cmd, {cwd: path.dirname @latex.mainFile}, (err, stdout, stderr) =>
      if (err)
        @latex.logger.processError(
          """Failed SyncTeX (code #{err.code}).""", err.message
        )
        return
      record = @parseResult(stdout)
      if record['column'] < 0
        column = 0
      else
        column = record['column'] - 1
      row = record['line'] - 1
      if 'input' of record
        file = path.resolve(record['input'].replace(/(\r\n|\n|\r)/gm, ''))
        atom.workspace.open(file,
          initialLine: row
          initialColumn: column
          searchAllPanes: true
        )
        @latex.viewer.focusMain()
        editor = atom.workspace.getActiveTextEditor()
        marker = editor.markBufferRange(editor.getBuffer().rangeForRow(row))
        decoration = editor.decorateMarker(marker,{type: 'highlight', class:'synctex-box'})
        setTimeout(( => decoration.destroy()), 500)
      else
        @latex.logger.processError(
          """Failed SyncTeX. No file path is given.""", record
        )
    )
