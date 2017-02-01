{ Disposable } = require 'atom'
fs = require 'fs'
path = require 'path'

module.exports =
class Manager extends Disposable
  constructor: (latex) ->
    @latex = latex

  findMain: ->
    if @latex.mainFile != undefined
      return true

    docRegex = /\\begin{document}/
    editor = atom.workspace.getActivePaneItem()
    currentPath = editor?buffer.file?.path
    currentContent = editor?.getText()

    if currentPath and currentContent
      if ((path.extname currentPath) == '.tex') and
          (currentContent.match docRegex)
        @latex.mainFile = currentPath
        return true

    for rootDir in atom.project.getPaths()
      for file in fs.readdirSync rootDir
        if (path.extname file) != '.tex'
          continue
        filePath = path.join rootDir, file
        fileContent = fs.readFileSync filePath, 'utf-8'
        if fileContent.match docRegex
          @latex.mainFile = filePath
          return true
    return false
