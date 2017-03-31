{ Disposable } = require 'atom'
path = require 'path'
fs = require 'fs'

module.exports =
class SubFiles extends Disposable
  constructor: (latex) ->
    @latex = latex
    @suggestions = []

  provide: (prefix,images) ->
    suggestions = []
    if prefix.length > 0
      for item in @suggestions
        if item.text.indexOf(prefix) > -1
          item.replacementPrefix = prefix
          suggestions.push item
      suggestions.sort((a, b) ->
        return a.text.indexOf(prefix) - b.text.indexOf(prefix))
      return suggestions

    if !@latex.manager.findAll()
      return suggestions

    items = []
    editor = atom.workspace.getActiveTextEditor()
    items = @getFileItems editor.getPath() , images?
    for item in items
      suggestions.push item

    suggestions.sort((a, b) ->
      return -1 if a.text < b.text
      return 1)
    @suggestions = suggestions
    return suggestions

  getFileItems: (currentPath,images) ->
    items = []
    dirName = path.dirname(currentPath)
    imgExts = ['.jpg','.png','.pdf','.eps']
    classNames = ['image-icon','image-icon','icon-file-pdf','postscript']
    results =  @traverseTree dirName
    for result in results
      try
        if !images and @latex.manager.isTexFile(result)
          relPath = path.relative(dirName,result)
          items.push
           text: relPath.substr(
                    0, relPath.lastIndexOf('.')).replace( /\\/g, "/")
           type: 'tag'
           rightLabel: path.extname(relPath).replace(".", "")
           iconHTML: '<i class="tex-icon"></i>'
           latexType: 'files'
         else if images and path.extname(result) in imgExts
           relPath = path.relative(dirName,result)
           extType = path.extname(relPath)
           items.push
            text: relPath.substr(
                     0, relPath.lastIndexOf('.')).replace( /\\/g, "/")
            type: 'tag'
            rightLabel: extType.replace(".", "")
            iconHTML: """<i class="#{classNames[imgExts.indexOf(extType)]}"></i>"""
            latexType: 'files'
      catch e

    return items

  traverseTree: (dirName) ->
    flatten = (array) ->
      flat = []
      for element in array
        if Array.isArray(element)
          flat = flat.concat flatten element
        else
          flat.push element
      flat
    walkSync = (dir) ->
      if !fs.lstatSync(dir).isDirectory()
        return dir
      fs.readdirSync(dir).map (f) ->
        walkSync path.join(dir, f)

    return flatten walkSync dirName
