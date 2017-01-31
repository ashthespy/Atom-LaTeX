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
    @buildProcess()

    return true

  buildProcess: ->
    cmd = @cmds.shift()
    if cmd == undefined
      @postBuild()
      return

    @buildLogs.push ''
    @execCmds.push cmd
    @latex.logPanel.showText icon: 'sync', spin: true,
      """Building LaTeX: Step #{@buildLogs.length}."""
    @process = cp.exec(
      cmd, {cwd: path.dirname @latex.mainFile}, (err, stdout, stderr) =>
        @process = undefined
        if !err
          @buildProcess()
        else
          @cmds = []
          @latex.logPanel.showText icon: 'x',
            """Failed building LaTeX.""", 3000
          atom.notifications.addError(
            """Failed Building LaTeX (code #{err.code}).""",
            {"detail": err.message}
          )
    )

    @process.stdout.on 'data', (data) =>
      @buildLogs[@buildLogs.length - 1] += data

  postBuild: ->
    @latex.logPanel.showText icon: 'check',
      """Successfully built LaTeX.""", 3000

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
    texCompiler = 'pdflatex'
    bibCompiler = 'bibtex'
    args = '-synctex=1 -interaction=nonstopmode -file-line-error'
    toolchain = [
      '%TEX %ARG %DOC',
      '%BIB %DOC',
      '%TEX %ARG %DOC',
      '%TEX %ARG %DOC',
    ]
    @cmds = []
    result = []
    for toolPrototype in toolchain
      cmd = toolPrototype
      cmd = cmd.split('%TEX').join(texCompiler)
      cmd = cmd.split('%BIB').join(bibCompiler)
      cmd = cmd.split('%ARG').join(args)
      cmd = cmd.split('%DOC').join(path.basename(@latex.mainFile, '.tex'))
      @cmds.push cmd

    return true
