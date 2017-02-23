{ Disposable } = require 'atom'
path = require 'path'
fs = require 'fs'

module.exports =
class Cleaner extends Disposable
  constructor: (latex) ->
    @latex = latex

  clean: ->
    if !@latex.manager.findMain()
      return false
    rootDir = path.dirname(@latex.mainFile)
    removeExt = atom.config.get('atom-latex.file_ext_to_clean')\
      .replace(/\s/,'').split(',')
    for file in fs.readdirSync rootDir
      if removeExt.indexOf((path.extname file).slice(1)) > -1
        fullPath = path.resolve(rootDir, file)
        fs.unlink(fullPath)
    return true
