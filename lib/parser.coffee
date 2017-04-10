{ Disposable } = require 'atom'
path = require 'path'

latexFile = /^.*?\(\.\/(.*?\.\w+)/
latexPattern = /^Output\swritten\son\s(.*)\s\(.*\)\.$/gm
latexFatalPattern = /Fatal error occurred, no output PDF file produced!/gm
latexError = /^(?:(.*):(\d+):|!)(?: (.+) Error:)? (.+?)\.?$/
latexBox = /^((?:Over|Under)full \\[vh]box \([^)]*\)) in paragraph at lines (\d+)--(\d+)$/
latexWarn = /^((?:(?:Class|Package) \S+)|LaTeX) (Warning|Info):\s+(.*?)(?: on input line (\d+))?\.$/

latexmkPattern = /^Latexmk:\sapplying\srule/gm
latexmkPatternNoGM = /^Latexmk:\sapplying\srule/
latexmkUpToDate = /^Latexmk: All targets \(.*\) are up-to-date/

araraPattern = /Running\s(?:[a-zA-Z]*)\.\.\./g
araraFailurePattern = /(FAILURE)/g
module.exports =
class Parser extends Disposable
  constructor: (latex) ->
    @latex = latex

  parse: (log) ->
    @latex.package.status.view.status = 'good'
    @isLatexmkSkipped = false
    if log.match(latexmkPattern)
      log = @trimLatexmk log
    if log.match(araraPattern)
      log = @trimArara log
    if log.match(latexPattern) or log.match(latexFatalPattern) or log.match(araraFailurePattern)
      @parseLatex log
    else if @latexmkSkipped(log)
      @latex.package.status.view.status = 'skipped'
      @isLatexmkSkipped = true
    @latex.package.status.view.update()
    @latex.panel.view.update()
    @lastFile = @latex.mainFile

  trimLatexmk: (log) ->
    log = log.replace(/(.{78}(\w|\s|\d|\\|\/))(\r\n|\n)/g, '$1')
    lines = log.replace(/(\r\n)|\r/g, '\n').split('\n')
    finalLine = -1
    for index of lines
      line = lines[index]
      result = line.match latexmkPatternNoGM
      if result
        finalLine = index
    return lines.slice(finalLine).join('\n')

  latexmkSkipped: (log) ->
    lines = log.replace(/(\r\n)|\r/g, '\n').split('\n')
    if lines[0].match(latexmkUpToDate)
      return true
    return false

  trimArara: (log) ->
    araraRunIdx = []
    lines = log.replace(/(\r\n)|\r/g, '\n').split('\n')
    for index of lines
      line = lines[index]
      result = line.match(/Running\s(?:[a-zA-Z]*)\.\.\./)
      if result
        araraRunIdx = araraRunIdx.concat index
    # Return only last arara run
    return lines.slice(araraRunIdx.slice(-1)[0]).join('\n')

  parseLatex: (log) ->
    log = log.replace(/(.{78}(\w|\s|\d|\\|\/))(\r\n|\n)/g, '$1')
    lines = log.replace(/(\r\n)|\r/g, '\n').split('\n')
    items = []
    for line in lines
      file = line.match latexFile
      if file
        @lastFile = path.resolve(path.dirname(@latex.mainFile), file[1])

      result = line.match latexBox
      if result
        items.push
          type: 'typesetting',
          text: result[1]
          file: @lastFile
          line: parseInt(result[2], 10)
        continue
      result = line.match latexWarn
      if result
        items.push
          type: 'warning',
          text: result[3]
          file: @lastFile
          line: parseInt result[4]
        continue
      result = line.match latexError
      if result
        items.push
          type: 'error',
          text: if result[3] and result[3] != 'LaTeX' then \
                """#{result[3]}: #{result[4]}""" else result[4],
          file: if result[1] then \
            path.resolve(path.dirname(@latex.mainFile), result[1]) else \
            @latex.mainFile
          line: if result[2] then parseInt result[2], 10 else undefined
        continue

    types = items.map((item) -> item.type)
    if types.indexOf('error') > -1
      @latex.package.status.view.status = 'error'
    else if types.indexOf('warning') > -1
      @latex.package.status.view.status = 'warning'
    else if types.indexOf('typesetting') > -1
      @latex.package.status.view.status = 'typesetting'
    @latex.logger.log = @latex.logger.log.concat items
