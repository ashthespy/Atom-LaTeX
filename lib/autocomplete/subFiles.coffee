{ Disposable } = require 'atom'
path = require 'path'
fs = require 'fs-plus'

module.exports =
class SubFiles extends Disposable
  constructor: (latex) ->
    @latex = latex
    @suggestions = []
    @items = []

  provide: (prefix,latexType) ->
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
        FileExts.push ".tex" , ".bib" , @latex.manager.config.latex_ext...
      # Filter results
      results = fs.listTreeSync(dirName).filter (res) -> return \
       res.match(///(|[\/\\])\.(?:#{FileExts.join("|").replace(/\./g,'')})///g)
      @getFileItems(file) for file in results

    activeFile = atom.project.relativizePath(atom.workspace.getActiveTextEditor().getPath())[1]
    # Push filtered items to suggestions
    for item in @items when item.latexType is (latexType || 'files-tex') and\
      item.relPath isnt activeFile
        suggestions.push item

    suggestions.sort((a, b) ->
      return -1 if a.text < b.text
      return 1)
    @suggestions = suggestions
    return suggestions

  getFileItems: (file) ->
    dirName = path.dirname(@latex.mainFile)
    relPath = path.relative(dirName,file)
    extType = path.extname(relPath)
    if ImageTypes[extType]?
      latexType = 'files-img'
    else if extType == '.bib'
      latexType = 'files-bib'
    else
      latexType = 'files-tex'
    try
      @items.push
        relPath: relPath
        text: relPath.replace(/\\/g, '/').replace(///\.(?:tex|#{FileExtsRegString})///,'')
        displayText: relPath.substr(
                 0, relPath.lastIndexOf('.')).replace( /\\/g,'/')
        rightLabel: extType.replace('.','')
        iconHTML: """<i class="#{(ImageTypes[extType] || FileTypes[extType] || "icon-file-text")}"></i>"""
        latexType: latexType
    catch error
      console.log error

  resetFileItems:(file) ->
    if file?
      relPath = path.relative(path.dirname(@latex.mainFile),file)
      pos = @items.map((item) -> item.relPath).indexOf(relPath)
      @items.splice(pos,1)
    else
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
  '.bib': "bibtex-icon medium-yellow icon-file-text"

# String of file types to strip extentions
FileExtsRegString = "#{Object.keys(ImageTypes).join("|").replace(/\./g,'')}"
