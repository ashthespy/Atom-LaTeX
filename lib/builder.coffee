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
    if atom.config.get('atom-latex.save_on_build')
      @saveonBuild()
    @latex.logger.log = []
    @latex.package.status.view.status = 'building'
    @latex.package.status.view.update()
    @buildLogs = []
    @execCmds = []
    @buildProcess()

    return true

  saveonBuild: ->
    if !@latex?.texFiles
      @latex.manager.findAll()
    for editor in atom.workspace.getTextEditors()
      if editor.isModified() and editor.getPath() in @latex.texFiles
        editor.save()

  execCmd: (cmd, env, cb) ->
    env.maxBuffer = Infinity
    return cp.exec(cmd, env, cb)

  buildProcess: ->
    cmd = @cmds.shift()
    if cmd == undefined
      @postBuild()
      return

    if atom.config.get('atom-latex.hide_log_if_success')
      @latex.panel.view.showLog = false
    @buildLogs.push ''
    @execCmds.push cmd
    # @latex.logPanel.showText icon: 'sync', spin: true, 'Building LaTeX.'
    @latex.logger.log.push({
      type: 'status',
      text: """Step #{@buildLogs.length}> #{cmd}"""
    })
    @process = @execCmd(
      cmd, {cwd: path.dirname @latex.mainFile}, (err, stdout, stderr) =>
        @process = undefined
        if !err or (err.code is null)
          @buildProcess()
        else
          @latex.panel.view.showLog = true
          @latex.logger.processError(
            """Failed Building LaTeX (code #{err.code}).""", err.message, true,
            [{
              text: "Dismiss"
              onDidClick: => @latex.logger.clearBuildError()
            }, {
              text: "Show build log"
              onDidClick: => @latex.logger.showLog()
            }]
          )
          @cmds = []
          # @latex.logPanel.showText icon: @latex.parser.status, 'Error.', 3000
          @latex.logger.log.push({
            type: 'status',
            text: 'Error occurred while building LaTeX.'
          })
          @latex.parser.parse @buildLogs?[@buildLogs?.length - 1]
    )

    @process.stdout.on 'data', (data) =>
      @buildLogs[@buildLogs.length - 1] += data

  postBuild: ->
    @latex.logger.clearBuildError()
    @latex.parser.parse @buildLogs?[@buildLogs?.length - 1]
    if @latex.parser.isLatexmkSkipped
      logText = 'latexmk skipped building process.'
    else
      logText = 'Successfully built LaTeX.'
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
    @process?.kill()

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
        @escapeFileName(path.basename(@latex.mainFile, '.tex'))
      )
      @cmds.push cmd

  escapeFileName: (file) ->
    if file.indexOf(' ') > -1
      return '"' + file + '"'
    return file
