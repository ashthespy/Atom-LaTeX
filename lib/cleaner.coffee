{ Disposable } = require 'atom'
path = require 'path'
fs = require 'fs'
glob = require 'glob'

module.exports =
class Cleaner extends Disposable
  constructor: (latex) ->
    @latex = latex

  clean: ->
    if !@latex.manager.findMain()
      return false
    rootDir = path.dirname(@latex.mainFile)
    removeGlobs = atom.config.get('atom-latex.file_ext_to_clean')\
      .replace(/\s/,'').split(',')
    for removeGlob in removeGlobs
      glob(removeGlob, cwd: rootDir, (err, files) ->
        if err
          return
        for file in files
          fullPath = path.resolve(rootDir, file)
          fs.unlink(fullPath)
      )
    return true
