{ Disposable } = require 'atom'
path = require 'path'

fileName = /^.*?\(\.?\/?([^\)\s]*?)\.\w+/
latexFile = /^.*?\(\.?\/?([^\)\s]*?\.\w+)/
latexPattern = /^Output\swritten\son\s(.*)\s\(.*\)\.$/gm
latexFatalPattern = /Fatal error occurred, no output PDF file produced!/gm
latexError = /^(?:(.*):(\d+):|!)(?: (.+) Error:)? (.+?)\.?$/gm
latexBox = /^((?:Over|Under)full \\[vh]box \([^)]*\)) (?:in paragraph at lines|has occurred while \\output is active) \[?(\d+)[-.]+(\d+)\]?\)?$/gm
latexWarn = /^((?:(?:Class|Package) \S+)|LaTeX(?: Font)?) (Warning|Info):\s+([\s\S]*?)(?: on input line (\d+))?\.$/gm

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
    files = []
    fileInds = []
    i = 0
    while i < log.length
      if log[i] == "("
        name = log.slice(i).match fileName
        if name && \
        # Escape evey non-alpha char when building up Regex 
        log.match ///#{name[1].replace(/(?=\W)/g, '\\')}\.aux///g
          fileInds.push [files.length, 0]
          files.push "("
        else
          if fileInds.length > 0
            fileInds[fileInds.length - 1][1] += 1
            files[fileInds[fileInds.length - 1][0]] += "("
      else
        if log[i] == ")"
          if fileInds.length > 0
            files[fileInds[fileInds.length - 1][0]] += ")"
            if fileInds[fileInds.length - 1][1] > 0
              fileInds[fileInds.length - 1][1] -= 1
            else
              fileInds.pop()
        else
          if fileInds.length > 0
            files[fileInds[fileInds.length - 1][0]] += log[i]
      i += 1

    items = []
    for file in files
      res_latexfile = file.match(latexFile)
      if res_latexfile?
        @lastFile = path.resolve(path.dirname(@latex.mainFile), res_latexfile[1])
      else 
        console.log """Not parsing #{file} from logs - #{res_latexfile}"""
        continue

      while result = latexBox.exec file
        items.push
          type: 'typesetting',
          text: result[1].replace /\s\s+/g, ' '
          file: @lastFile
          line: parseInt result[2], 10

      while result = latexWarn.exec file
        items.push
          type: 'warning',
          text: result[3].replace /\s\s+/g, ' '
          file: @lastFile
          line: parseInt result[4]

      while result = latexError.exec file
        items.push
          type: 'error',
          text: if result[3] and result[3] != 'LaTeX' then \
                """#{result[3]}: #{result[4]}""" else result[4],
          file: if result[1] then \
            path.resolve(path.dirname(@latex.mainFile), result[1]) else \
            @latex.mainFile
          line: if result[2] then parseInt result[2], 10 else undefined

    types = items.map((item) -> item.type)
    if types.indexOf('error') > -1
      @latex.package.status.view.status = 'error'
    else if types.indexOf('warning') > -1
      @latex.package.status.view.status = 'warning'
    else if types.indexOf('typesetting') > -1
      @latex.package.status.view.status = 'typesetting'
    @latex.logger.log = @latex.logger.log.concat items
