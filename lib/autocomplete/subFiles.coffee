{ Disposable } = require 'atom'
path = require 'path'
fs = require 'fs-plus'

module.exports =
class SubFiles extends Disposable
  constructor: (latex) ->
    @latex = latex
    @suggestions = []
    @items = []

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

    if @latex.manager.disable_watcher
      dirName = path.dirname(@latex.mainFile)
      results =  fs.listTreeSync(dirName)
      FileExts = Object.keys(ImageTypes)
      if @latex.manager.config?.latex_ext?
        FileExts.push ".tex" , @latex.manager.config.latex_ext...
      # Filter results
      results = fs.listTreeSync(dirName).filter (res) -> return \
       res.match(///(|[\/\\])\.(?:#{FileExts.join("|").replace(/\./g,'')})///g)
      @getFileItems(file,!@latex.manager.isTexFile(file)) for file in results

    activeFile = atom.workspace.getActiveTextEditor().getPath()
    for item in @items when item.texImage is images? and\
       item.text isnt path.basename(activeFile,path.extname(activeFile))
        suggestions.push item

    suggestions.sort((a, b) ->
      return -1 if a.text < b.text
      return 1)
    @suggestions = suggestions
    return suggestions

  getFileItems: (file,images,splice) ->
    dirName = path.dirname(@latex.mainFile)
    try
      if !images and !splice?
        relPath = path.relative(dirName,file)
        extType = path.extname(relPath)
        @items.push
         text: relPath.replace(/\\/g, "/").replace(/(\.tex)/g,"")
         displayText: relPath.substr(
                  0, relPath.lastIndexOf('.')).replace( /\\/g, "/")
         rightLabel: extType.replace(".", "")
         iconHTML: """<i class="#{(FileTypes[extType] || "icon-file-text")}"></i>"""
         latexType: 'files'
         texImage: false
      else if images and !splice?
         relPath = path.relative(dirName,file)
         extType = path.extname(relPath)
         @items.push
          text: relPath.substr(
                   0, relPath.lastIndexOf('.')).replace( /\\/g, "/")
          rightLabel: extType.replace(".", "")
          iconHTML: """<i class="#{ImageTypes[extType]}"></i>"""
          latexType: 'files'
          texImage: true
      else if splice?
        relPath = path.relative(dirName,file)
        extType = path.extname(relPath)
        for item in @items when item.text is relPath.substr(
                 0, relPath.lastIndexOf('.')).replace( /\\/g, "/")
          pos =  @items.map (item) -> item.text.indexOf(relPath.substr(
                   0, relPath.lastIndexOf('.')).replace( /\\/g, "/"))
          @items.splice(pos.indexOf(0),1)
    catch e
      console.log e

  resetFileItems: ->
    @items = []

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
