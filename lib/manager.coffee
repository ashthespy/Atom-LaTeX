{ Disposable } = require 'atom'
fs = require 'fs'
path = require 'path'
chokidar = require 'chokidar'

module.exports =
class Manager extends Disposable
  constructor: (latex) ->
    @latex = latex
    @disable_watcher = atom.config.get "atom-latex.disable_watcher"
    @watched = []
  rootDir: ->
    # Collect all open TextEditors with LaTeX grammar
    texEditors = (editor for editor in atom.workspace.getTextEditors()\
                    when editor.getGrammar().scopeName.match(/text.tex.latex/))
    if atom.workspace.getActiveTextEditor() in texEditors # An active TeXeditor is open
      return atom.project.relativizePath(atom.workspace.getActiveTextEditor().getPath())[0]
    else if texEditors.length > 0   # First open editor with LaTeX grammar
      return atom.project.relativizePath(texEditors[0].getPath())[0]
    else # backup, return first active project
        @latex.logger.log.push {
          type: status
          text: "No active TeX editors were open - Setting Project: #{atom.project.getPaths()[0]}"
        }
      return atom.project.getPaths()[0]

  loadLocalCfg: ->
    if @lastCfgTime? and Date.now() - @lastCfgTime < 200 or\
       !atom.workspace.getActiveTextEditor()?
      return @config?
    @lastCfgTime = Date.now()
    rootDir = @rootDir()
    return false if !rootDir?
    if '.latexcfg' in fs.readdirSync rootDir
      try
        filePath = path.join rootDir, '.latexcfg'
        fileContent = fs.readFileSync filePath, 'utf-8'
        @config = JSON.parse fileContent
        if @config.root?
          @config.root = path.resolve rootDir, @config.root
        return true
      catch err
        console.log err
    return false

  isTexFile: (name) ->
    @latex.manager.loadLocalCfg()
    if path.extname(name) in ['.tex','.tikz'] or \
        @latex.manager.config?.latex_ext?.indexOf(path.extname(name)) > -1
      return true
    return false
    
  getDocandExt: (fpath) ->
    @latex.manager.loadLocalCfg()
    extnames = ['.tex','.tikz']
    # Check custom extensions first to handle stuff like `main.tex.tikz`
    if @latex.manager.config?.latex_ext?
      extnames = Array.from(new Set(@latex.manager.config.latex_ext.concat(extnames)));
    for ext in extnames
      if path.basename(fpath).endsWith(ext)
        return [path.basename(fpath).replace(ext,''), ext.slice(1)]
        
  findMain: (here) ->
    result = @findMainSequence(here)
    if result and !fs.existsSync(@latex.mainFile)
      @latex.logger.processError(
        "Invalid LaTeX root file `#{path.basename(@latex.mainFile)}`",
        "The path #{@latex.mainFile} does not exist!", true,
        [{
          text: "Set LaTeX root"
          onDidClick: =>
            @latex.manager.refindMain()
            @latex.logger.clearBuildError()
        }])
      return false
    @latex.panel.view.update()
    @latex.mainDoc = @getDocandExt(@latex.mainFile)
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
    editor = atom.workspace.getActiveTextEditor()
    currentPath = editor?.getPath()
    currentContent = editor?.getText()

    if currentPath and currentContent
      if @isTexFile(currentPath) and currentContent.match(docRegex)
        @latex.mainFile = currentPath
        @latex.logger.setMain('self')
        return true
    return false

  findMainSelfMagic: ->
    magicRegex = /(?:%\s*!TEX\sroot\s*=\s*([^\s]*\.tex)$)/m
    editor = atom.workspace.getActiveTextEditor()
    currentPath = editor?.getPath()
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
    # //some.path/tex/mainFile.rev1.tex -> /some.path/tex/mainFile.rev1.pdf
    pdfPath = @latex.mainFile.replace(///#{@latex.mainDoc[1]}$///, 'pdf')
    @latex.logger.debuglog.info("""PDF path: #{pdfPath}""")
    return pdfPath

  prevWatcherClosed: (watcher, watchPath) ->
    watchedPaths = watcher.getWatched()
    if !( watchPath of watchedPaths)
      # rootWatcher exists, but project dir has been changed
      # and reset all suggestions and close watcher
      @latex.provider.command.resetCommands()
      @latex.provider.reference.resetRefItems()
      @latex.provider.subFiles.resetFileItems()
      @latex.provider.citation.resetBibItems()
      watcher.close()
      return true
    else
      return false

  watchRoot: ->
    root = @rootDir()
    return false if !root?
    if !@rootWatcher? or @prevWatcherClosed(@rootWatcher,root)
      @latex.logger.log.push {
        type: status
        text: "Watching project #{root} for changes"
      }
      watchFileExts = ['png','eps','jpeg','jpg','pdf','tex','bib']
      if @latex.manager.config?.latex_ext?
        watchFileExts.push @latex.manager.config.latex_ext...
      @rootWatcher = chokidar.watch(root,{
        ignored: ///(|[\/\\])\.(?!#{watchFileExts.join("|").replace(/\./g,'')})///g
        })
      @watched.push(root)
      console.time('RootWatcher Init')
      @rootWatcher.on('add',(fpath)=>
        @watchActions(fpath,'add')
        return)
      @rootWatcher.on('ready',
      () =>
        @rootWatcher.on('change', (fpath,stats) =>
          if @isTexFile(fpath)
            if fpath == @latex.mainFile
              # Update dependent files
              @latex.texFiles = [ @latex.mainFile ]
              @latex.bibFiles = []
              @findDependentFiles(@latex.mainFile)
            @watchActions(fpath)
          return)
        @rootWatcher.on('unlink',(fpath) =>
          @watchActions(fpath,'unlink')
          return)
        console.timeEnd('RootWatcher Init')
      )
      return true

    return false

  watchActions: (fpath,event) ->
    # Push/Splice file suggestions on new file additions or removals
    if event is 'add'
      @latex.provider.subFiles.getFileItems(fpath)
    else if event is 'unlink'
      @latex.provider.subFiles. resetFileItems(fpath)
      @latex.provider.reference.resetRefItems(fpath)
    if @isTexFile(fpath)
      # Push command and references suggestions
      @latex.provider.command.getCommands(fpath)
      @latex.provider.reference.getRefItems(fpath)

  findAll: ->
    if !@findMain()
      return false
    findFiles = () =>
        @latex.texFiles = [ @latex.mainFile ]
        @latex.bibFiles = []
        @findDependentFiles(@latex.mainFile)    
    if @disable_watcher or @watchRoot()
      findFiles()
      if @disable_watcher
        @watchActions(file,'add') for file in @latex.texFiles
    else if !@rootDir()?
      findFiles()
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
      @addBibToWatcher(bib) for bib in bibs

    # Reset Citations
    for fpath in @watched
      # The race is on b/w this test and setting up bibWatcher, hence the first check
      if fpath? and fpath not in @latex.bibFiles and !(fpath.indexOf('.bib') < 0)
        # bib file removed, remove citation suggestions and unwatch
        @latex.provider.citation.resetBibItems(fpath)
        @bibWatcher.unwatch(fpath)
        @watched.splice(@watched.indexOf(fpath),1)
    return true

  addBibToWatcher: (bib) ->
    if path.extname(bib) is ''
      bib += '.bib'
    bib = path.resolve(path.join(path.dirname(@latex.mainFile),bib))
    if @latex.bibFiles.indexOf(bib) < 0
      @latex.bibFiles.push(bib)
    if @disable_watcher
      @latex.provider.citation.getBibItems(bib)
      return
    # Init bibWatcher listeners
    if !@bibWatcher? or @bibWatcher.closed
      @bibWatcher = chokidar.watch(bib)
      @watched.push(bib)
      @latex.logger.debuglog.info("Watching bib file #{bib} for changes")
      # Register watcher callbacks
      @bibWatcher.on('add', (fpath) =>
        # bib file added, parse
        @latex.provider.citation.getBibItems(fpath)
        @latex.logger.debuglog.info("Added bib file #{fpath} to Watcher")
        return)
      @bibWatcher.on('change', (fpath) =>
        # bib file changed, reparse
        @latex.provider.citation.getBibItems(fpath)
        return)
      @bibWatcher.on('unlink', (fpath) =>
        # bib file deleted, remove citation suggestions and unwatch
        @latex.provider.citation.resetBibItems(fpath)
        @bibWatcher.unwatch(fpath)
        @watched.splice(@watched.indexOf(fpath),1)
        return)
    else if bib not in @watched
      # Process new unwatched bib file
      @bibWatcher.add(bib)
      @watched.push(bib)
