{ Disposable } = require 'atom'
path = require 'path'
fs = require 'fs-plus'

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
    results =  fs.listTreeSync(dirName)
    for result in results
      try
        if !images and @latex.manager.isTexFile(result) and result isnt currentPath
          relPath = path.relative(dirName,result)
          extType = path.extname(relPath)
          items.push
           text: relPath.substr(
                    0, relPath.lastIndexOf('.')).replace( /\\/g, "/")
           rightLabel: extType.replace(".", "")
           iconHTML: """<i class="#{if extType of FileTypes then FileTypes[extType] else  "icon-file-text"}"></i>"""
           latexType: 'files'
         else if images and path.extname(result) of ImageTypes
           relPath = path.relative(dirName,result)
           extType = path.extname(relPath)
           items.push
            text: relPath.substr(
                     0, relPath.lastIndexOf('.')).replace( /\\/g, "/")
            rightLabel: extType.replace(".", "")
            iconHTML: """<i class="#{ImageTypes[extType]}"></i>"""
            latexType: 'files'
      catch e

    return items

# Use file-icons as default with Git Octicons as backups
ImageTypes =
  '.png':   "medium-orange icon-file-media"
  '.eps':   "postscript-icon medium-orange icon-file-media"
  '.jpeg':  "medium-green icon-file-media"
  '.jpg':   "medium-green icon-file-media"
  '.pdf':   "medium-red icon-file-pdf"
FileTypes  =
  '.tex': "tex-icon medium-blue icon-file-text"
  '.cls': "tex-icon medium-orange icon-file-text"
  '.tikz': "tex-icon medium-green icon-file-text"
  '.Rnw': "tex-icon medium-green icon-file-text"
