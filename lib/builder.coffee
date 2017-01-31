{ Disposable } = require 'atom'
path = require 'path'
cp = require 'child_process'
hb = require 'hasbin'

module.exports =
class Builder extends Disposable
  constructor: (latex) ->
    super () => @disposables.dispose()
    @latex = latex

  build: ->
    if !@binCheck()
      return false
    if !@latex.manager.findMain()
      return false

    @killProcess()
    @setCmds()
    @buildLogs = []
    @execCmds = []
    @latex.logPanel.clear()
    @buildProcess()

    return true

  buildProcess: ->
    cmd = @cmds.shift()
    if cmd == undefined
      @postBuild()
      return

    @buildLogs.push ''
    @execCmds.push cmd
    @latex.logPanel.showText icon: 'sync', spin: true, 'Building LaTeX.'
    @latex.logPanel.addStepLog(@buildLogs.length, cmd)
    @process = cp.exec(
      cmd, {cwd: path.dirname @latex.mainFile}, (err, stdout, stderr) =>
        @process = undefined
        if !err
          @buildProcess()
        else
          atom.notifications.addError(
            """Failed Building LaTeX (code #{err.code}).""", {
              detail: err.message
              dismissable: true
            })
          @cmds = []
          @latex.logPanel.showText icon: 'x', 'Error.', 3000
          @latex.logPanel.addPlainLog 'Error occurred while building LaTeX.'
          @latex.parser.parse @buildLogs?[@buildLogs?.length - 1]
    )

    @process.stdout.on 'data', (data) =>
      @buildLogs[@buildLogs.length - 1] += data

  postBuild: ->
    @latex.logPanel.showText icon: 'check', 'Success.', 3000
    @latex.logPanel.addPlainLog 'Successfully built LaTeX.'
    @latex.parser.parse @buildLogs?[@buildLogs?.length - 1]
    if atom.config.get('atom-latex.preview_after_build') and
        @latex.viewer.client.ws == undefined
      @latex.viewer.openViewerTab()
    else if @latex.viewer.client.ws?
      @latex.viewer.refresh()

  killProcess: ->
    @cmds = []
    @process?.kill()

  binCheck: (binary) ->
    if binary
      if hb.sync binary
        return true
      return false

    if !hb.sync 'pdflatex'
      return false
    if !hb.sync 'bibtex'
      return false
    return true

  setCmds: ->
    if atom.config.get('atom-latex.toolchain') == 'auto'
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
      #{path.basename(@latex.mainFile, '.tex')}"""
    ]
    if !@binCheck('latexmk') or !@binCheck('perl')
      return false
    return true

  custom_toolchain: ->
    texCompiler = atom.config.get('atom-latex.compiler')
    bibCompiler = atom.config.get('atom-latex.bibtex')
    args = atom.config.get('atom-latex.compiler_param')
    toolchain = atom.config.get('atom-latex.custom_toolchain').split('&&')
    toolchain = toolchain.map((cmd) -> cmd.trim())
    @cmds = []
    result = []
    for toolPrototype in toolchain
      cmd = toolPrototype
      cmd = cmd.split('%TEX').join(texCompiler)
      cmd = cmd.split('%BIB').join(bibCompiler)
      cmd = cmd.split('%ARG').join(args)
      cmd = cmd.split('%DOC').join(path.basename(@latex.mainFile, '.tex'))
      @cmds.push cmd
