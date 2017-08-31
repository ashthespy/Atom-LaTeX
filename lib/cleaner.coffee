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
    FileExts = atom.config.get('atom-latex.file_ext_to_clean')\
      .replace(/\*\./g,'').replace(/\,\s/g,'|')
    glob("**/*.*(#{FileExts})", cwd: rootDir, (err, files) ->
      if err
        console.log err
        return
      for file in files
        fullPath = path.resolve(rootDir, file)
        fs.unlink(fullPath,(e) ->
          console.log e if e?)
    )
    return true
