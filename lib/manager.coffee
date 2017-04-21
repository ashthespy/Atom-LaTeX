{ Disposable } = require 'atom'
fs = require 'fs'
path = require 'path'
chokidar = require 'chokidar'

module.exports =
class Manager extends Disposable
  rootDir: ->
    if atom.workspace.getActiveTextEditor()?
      return atom.project.relativizePath(atom.workspace.getActiveTextEditor().getPath())[0]
    else
      return atom.project.getPaths()[0] # backup, return first active project
  constructor: (latex) ->
    @latex = latex

  loadLocalCfg: ->
    if @lastCfgTime? and Date.now() - @lastCfgTime < 200 or\
       !atom.workspace.getActiveTextEditor()?
      return @config?
    @lastCfgTime = Date.now()
    rootDir = @rootDir()
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

    # Check if the mainFile is part of the curent project path
    if @latex.mainFile? and atom.project.relativizePath(@latex.mainFile)[0] == @rootDir()
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

  prevWatcherClosed: (watcher, watchPath) ->
    watchedPaths = watcher.getWatched()
    if watcher? and !( watchPath of watchedPaths)
      # rootWatcher exists, but project dir has been changed
      # and reset all suggestions and close watcher
      @latex.provider.command.resetCommands()
      @latex.provider.reference.resetRefItems()
      @latex.provider.subFiles.resetFileItems()
      watcher.close()
      return true
    else
      return false

  watchRoot: ->
    if !@rootWatcher? or @prevWatcherClosed(@rootWatcher,@rootDir())
      @latex.logger.log.push {
        type: status
        text: "Watching project #{@rootDir()} for changes"
      }
      watchFileExts = ['png','eps','jpeg','jpg','pdf','tex']
      if @latex.manager.config?.latex_ext?
        watchFileExts.push @latex.manager.config.latex_ext...
      @rootWatcher = chokidar.watch(@rootDir() + "/**/*.+(#{watchFileExts.join("|").replace(/\./g,'')})")

      @rootWatcher.on('add',(path)=>
        @watchActions(path,'add')
        return)

      @rootWatcher.on('change', (path,stats) =>
        if @isTexFile(path)
          if path == @latex.mainFile
            # Update dependent files
            @latex.texFiles = [ @latex.mainFile ]
            @latex.bibFiles = []
            @findDependentFiles(@latex.mainFile)
          @watchActions(path)
        return)
      @rootWatcher.on('unlink',(path) =>
        @watchActions(path,'unlink')
        return)
      return true

    return false

  watchActions: (path,event) ->
    # Push/Splice file suggestions on new file additions or removals
    if event is 'add'
      @latex.provider.subFiles.getFileItems(path, !@isTexFile(path))
    else if event is 'unlink'
      @latex.provider.subFiles.getFileItems(path,false,true) # don't bother checking file type
      @latex.provider.reference.resetRefItems(path)
    if @isTexFile(path)
      # Push command and references suggestions
      @latex.provider.command.getCommands(path)
      @latex.provider.reference.getRefItems(path)

  findAll: ->
    if !@findMain()
      return false
    if @watchRoot()
      @latex.texFiles = [ @latex.mainFile ]
      @latex.bibFiles = []
      @findDependentFiles(@latex.mainFile)
    return true

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
      if @latex.texFiles.indexOf(filePath) < 0 and fs.existsSync(filePath)
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
        if !@bibWatcher or @prevBibWatcherClosed(@bibWatcher,bib)
          @bibWatcher = chokidar.watch(bib)
          # Register watcher callbacks
          @bibWatcher.on('add', (path) =>
            # bib file added, reparse
            @latex.provider.citation.getBibItems(path)
            return)
          @bibWatcher.on('change', (path) =>
            # bib file changed, reparse
            @latex.provider.citation.getBibItems(path)
            return)
          @bibWatcher.on('unlink', (path) =>
            # bib file removed, close and reset citation suggestions
            @latex.provider.citation.resetBibItems(path)
            return)
      )
    return true

  prevBibWatcherClosed:(watcher,watchPath) ->
    watchedPaths = watcher.getWatched()
    if watcher? and path.basename(watchPath) not in watchedPaths[path.dirname(watchPath)]
      watcher.close()
      return true
    else
      return false
