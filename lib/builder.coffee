{ Disposable } = require 'atom'
path = require 'path'
cp = require 'child_process'
hb = require 'hasbin'

module.exports =
class Builder extends Disposable
  constructor: (latex) ->
    @latex = latex

  build: (here) ->
    if !@latex.manager.findMain(here)
      return false

    @killProcess()
    @setCmds()
    promise = Promise.resolve()
    if atom.config.get('atom-latex.save_on_build')
      promise = @saveonBuild()
    promise.then () =>
      @buildTimer = Date.now()
      @latex.logger.log = []
      @latex.package.status.view.status = 'building'
      @latex.package.status.view.update()
      @buildLogs = []
      @buildErrs = []
      @execCmds = []
      @buildProcess()

    return true

  saveonBuild: ->
    if !@latex?.texFiles
      @latex.manager.findAll()
    promises = []
    for editor in atom.workspace.getTextEditors()
      if editor.isModified() and editor.getPath() in @latex.texFiles
        promises.push editor.save()
    return Promise.all(promises)


  buildProcess: ->
    cmd = @cmds.shift()
    if cmd == undefined
      @postBuild()
      return

    if atom.config.get('atom-latex.hide_log_if_success')
      @latex.panel.view.showLog = false
    @buildLogs.push ''
    @buildErrs.push ''
    @execCmds.push cmd

    @latex.logger.log.push({
      type: 'status',
      text: """Step #{@buildLogs.length}> #{cmd}"""
    })
    # Split into array of cmd + arguments (un-escaping "" again)
    toolchain = cmd.match(/(?:[^\s"]+|"[^"]*")+/g).map((arg) -> arg.replace(/"/g,''))
    @currentProcess = cp.spawn(toolchain.shift(), toolchain, {cwd:path.dirname @latex.mainFile})

    # Register callbacks for the spawnprocess
    @currentProcess.stdout.on 'data', (data) =>
      @buildLogs[@buildLogs.length - 1] += data

    @currentProcess.stderr.on 'data', (data) =>
      @buildErrs[@buildErrs.length - 1] += data

    @currentProcess.on 'error', (err) =>
      # Fatal executable error
      throwErrors(err)
      @latex.parser.parse @buildLogs?[@buildLogs?.length - 1]
      @currentProcess = undefined

    @currentProcess.on 'exit' , (exitCode, signal) =>
      if !exitCode and !signal?     # Proceed if no error or kill signal
        @buildProcess()
      else
        # Build up err object with a default msg
        err =
          code: exitCode
          message: if @buildErrs.length > 1 then @buildErrs else  "Command Failed: " + cmd
        throwErrors(err,'Build Aborted!' if signal?)
        # Parse last command's log
        @latex.parser.parse @buildLogs?[@buildLogs?.length - 1]
        # Clear pending commands and currentProcess
        @cmds = []
      @currentProcess = undefined

    throwErrors = (err,title) =>
      @latex.package.status.view.status = 'error'
      @latex.panel.view.showLog = true
      @latex.logger.processError(
        title || """Failed Building LaTeX (code #{err.code}).""", err.message, true,
        [{
          text: "Dismiss"
          onDidClick: => @latex.logger.clearBuildError()
        }, {
          text: "Show build log"
          onDidClick: ()=>
            @latex.logger.clearBuildError()
            @latex.logger.showLog()
        }]
      )
      @latex.logger.log.push({
        type: 'error',
        text: 'Error occurred while building LaTeX.'
      })

  postBuild: ->
    @latex.logger.clearBuildError()
    @latex.parser.parse @buildLogs?[@buildLogs?.length - 1]
    if @latex.parser.isLatexmkSkipped
      logText = 'latexmk skipped building process.'
    else
      logText = "Successfully built LaTeX in #{Date.now() - @buildTimer} ms"
    @latex.logger.log.push({
      type: 'status',
      text: logText
    })
    @latex.panel.view.update()
    if @latex.viewer.client.ws?
      @latex.viewer.refresh()
    else if atom.config.get('atom-latex.preview_after_build') isnt\
        'Do nothing'
      @latex.viewer.openViewer()
    if atom.config.get('atom-latex.clean_after_build')
      @latex.cleaner.clean()

  killProcess: ->
    @cmds = []
    if @currentProcess?
      @latex.logger.log.push({
        type: 'warning',
        text: "Killing running LaTeX command (PID: #{@currentProcess.pid})"
      })
      # Kill entire process tree
      if process.platform is 'win32'
        killcmd = "taskkill -pid #{@currentProcess.pid} /T /F"
      else
        killcmd = "pkill -P #{@currentProcess.pid}"
      cp.exec(killcmd, (error, stdout, stderr) ->
        console.log error if error?
        console.log "> #{killcmd}\n\n#{stdout}" if stdout?
        console.log stderr if stderr)

  binCheck: (binary) ->
    if hb.sync binary
      return true
    return false

  setCmds: ->
    @latex.manager.loadLocalCfg()
    if @latex.manager.config?.toolchain
      @custom_toolchain(@latex.manager.config.toolchain)
    else if atom.config.get('atom-latex.toolchain') == 'auto'
      if !@latexmk_toolchain()
        @custom_toolchain()
    else if atom.config.get('atom-latex.toolchain') == 'latexmk toolchain'
      @latexmk_toolchain()
    else if atom.config.get('atom-latex.toolchain') == 'custom toolchain'
      @custom_toolchain()

  latexmk_toolchain: ->
    @cmds = [
      """latexmk \
      #{atom.config.get('atom-latex.latexmk_param')} \
      #{@escapeFileName(path.basename(@latex.mainFile, '.tex'))}"""
    ]
    if !@binCheck('latexmk') or !@binCheck('perl')
      return false
    return true

  custom_toolchain: (toolchain) ->
    texCompiler = atom.config.get('atom-latex.compiler')
    bibCompiler = atom.config.get('atom-latex.bibtex')
    args = atom.config.get('atom-latex.compiler_param')
    if !toolchain?
      toolchain = atom.config.get('atom-latex.custom_toolchain')
    toolchain = toolchain.split('&&').map((cmd) -> cmd.trim())
    @cmds = []
    result = []
    for toolPrototype in toolchain
      cmd = toolPrototype
      cmd = cmd.split('%TEX').join(texCompiler)
      cmd = cmd.split('%BIB').join(bibCompiler)
      cmd = cmd.split('%ARG').join(args)
      cmd = cmd.split('%DOC').join(
        # get basename and strip file extensions
        @escapeFileName(@latex.mainDoc[0])
      )
      cmd = cmd.split('%EXT').join(@latex.mainDoc[1])
      @cmds.push cmd

  escapeFileName: (file) ->
    if file.indexOf(' ') > -1
      return '"' + file + '"'
    return file
