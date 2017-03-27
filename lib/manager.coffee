{ Disposable } = require 'atom'
fs = require 'fs'
path = require 'path'

module.exports =
class Manager extends Disposable
  constructor: (latex) ->
    @latex = latex

  loadLocalCfg: ->
    if @lastCfgTime? and Date.now() - @lastCfgTime < 200
      return @config?
    @lastCfgTime = Date.now()
    editor = atom.workspace.getActivePaneItem()
    currentPath = editor?.buffer.file?.path
    currentDir = path.dirname(currentPath)
    if currentDir?
      dirs = [currentDir]
    else
      dirs = []
    for rootDir in dirs.concat(atom.project.getPaths())
      for file in fs.readdirSync rootDir
        if file is '.latexcfg'
          try
            filePath = path.join rootDir, file
            fileContent = fs.readFileSync filePath, 'utf-8'
            @config = JSON.parse fileContent
            if @config.root?
              @config.root = path.resolve rootDir, @config.root
            return true
          catch err
    return false

  isTexFile: (name) ->
    @latex.manager.loadLocalCfg()
    if path.extname(name) == '.tex' or \
        @latex.manager.config?.latex_ext?.indexOf(path.extname(name)) > -1
      return true
    return false

  findMain: (here) ->
    result = @findMainSequence(here)
    @latex.panel.view.update()
    return result

  refindMain: () ->
    input = document.getElementById('atom-latex-root-input')
    input.onchange = (=>
      if input.files.length > 0
        @latex.mainFile = input.files[0].path
      @latex.panel.view.update()
    )
    input.click()

  findMainSequence: (here) ->
    if here
      return true if @findMainSelfMagic()
      return true if @findMainSelf()

    if @latex.mainFile?
      return true

    return true if @findMainConfig()
    return true if @findMainSelfMagic()
    return true if @findMainSelf()
    return true if @findMainAllRoot()

    @latex.logger.missingMain()
    return false

  findMainSelf: ->
    docRegex = /\\begin{document}/
    editor = atom.workspace.getActivePaneItem()
    currentPath = editor?.buffer.file?.path
    currentContent = editor?.getText()

    if currentPath and currentContent
      if @isTexFile(currentPath) and currentContent.match(docRegex)
        @latex.mainFile = currentPath
        @latex.logger.setMain('self')
        return true
    return false

  findMainSelfMagic: ->
    magicRegex = /(?:%\s*!TEX\sroot\s*=\s*([^\s]*\.tex)$)/m
    editor = atom.workspace.getActivePaneItem()
    currentPath = editor?.buffer.file?.path
    currentContent = editor?.getText()

    if currentPath and currentContent
      if @isTexFile(currentPath)
        result = currentContent.match magicRegex
        if result
          @latex.mainFile = path.resolve(path.dirname(currentPath), result[1])
          @latex.logger.setMain('magic')
          return true
    return false

  findMainConfig: ->
    @loadLocalCfg()
    if @config?.root
      @latex.mainFile = @config.root
      @latex.logger.setMain('config')
      return true
    return false

  findMainAllRoot: ->
    docRegex = /\\begin{document}/
    for rootDir in atom.project.getPaths()
      for file in fs.readdirSync rootDir
        continue if !@isTexFile(file)
        filePath = path.join rootDir, file
        fileContent = fs.readFileSync filePath, 'utf-8'
        if fileContent.match docRegex
          @latex.mainFile = filePath
          @latex.logger.setMain('all')
          return true
    return false

  findPDF: ->
    if !@findMain()
      return false
    return path.join(
      path.dirname(@latex.mainFile),
      path.basename(@latex.mainFile, '.tex') + '.pdf')

  findAll: ->
    if !@findMain()
      return false
    @latex.texFiles = [ @latex.mainFile ]
    @latex.bibFiles = []
    @findDependentFiles(@latex.mainFile)

  findDependentFiles: (file) ->
    content = fs.readFileSync file, 'utf-8'
    baseDir = path.dirname(@latex.mainFile)

    inputReg = /(?:\\(?:input|include|subfile)(?:\[[^\[\]\{\}]*\])?){([^}]*)}/g
    loop
      result = inputReg.exec content
      break if !result?
      inputFile = result[1]
      if path.extname(inputFile) is ''
        inputFile += '.tex'
      filePath = path.resolve(path.join(baseDir, inputFile))
      if @latex.texFiles.indexOf(filePath) < 0
        @latex.texFiles.push(filePath)
        @findDependentFiles(filePath)

    bibReg = /(?:\\(?:bibliography|addbibresource)(?:\[[^\[\]\{\}]*\])?){(.+?)}/g
    loop
      result = bibReg.exec content
      break if !result?
      bibs = result[1].split(',').map((bib) -> bib.trim())
      paths = bibs.map((bib) =>
        if path.extname(bib) is ''
          bib += '.bib'
        bib = path.resolve(path.join(baseDir, bib))
        if @latex.bibFiles.indexOf(bib) < 0
          @latex.bibFiles.push(bib)
      )
    return true
