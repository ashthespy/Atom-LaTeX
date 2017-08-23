{ Disposable } = require 'atom'

module.exports =
class Provider extends Disposable
  constructor: ->

  deactivate: ->
    return @disposables.dispose()

  lazyLoad: (latex) ->
    @latex = latex

    Citation = require './autocomplete/citation'
    Reference = require './autocomplete/reference'
    Environment = require './autocomplete/environment'
    Command = require './autocomplete/command'
    Syntax = require './autocomplete/syntax'
    SubFiles = require './autocomplete/subFiles'
    @citation = new Citation(@latex)
    @reference = new Reference(@latex)
    @environment = new Environment(@latex)
    @command = new Command(@latex)
    @syntax = new Syntax(@latex)
    @subFiles = new SubFiles(@latex)

  provider:
    selector: '.text.tex.latex'
    inclusionPriority: 1
    suggestionPriority: 2
    getSuggestions: ({editor, bufferPosition}) ->
      new Promise (resolve) ->
        line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])
        if line[line.length - 1] is '{'
          atom.packages.getActivePackage('autocomplete-plus')\
            .mainModule.autocompleteManager.shouldDisplaySuggestions = true

        for command in ['citation', 'reference', 'environment', 'command', 'subFiles']
          suggestions = atom_latex.latex.provider.completeCommand(line, command)
          resolve(suggestions) if suggestions?

        resolve([])

    onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->
      if suggestion.chainComplete
        setTimeout(( -> atom.packages.getActivePackage('autocomplete-plus')\
          .mainModule.autocompleteManager.findSuggestions()), 100)
      if suggestion.latexType is 'environment'
        lines = editor.getBuffer().getLines()
        rowContent = lines[triggerPosition.row].slice(0, triggerPosition.column)
        if rowContent.indexOf('\\end') > rowContent.indexOf('\\begin')
          editor.setCursorBufferPosition(
            row: triggerPosition.row - 1
            column: lines[triggerPosition.row - 1].length
          )
          if suggestion.additionalInsert?
            editor.insertText(suggestion.additionalInsert)

  completeCommand: (line, type) ->
    switch type
      when 'citation'
        reg = /(?:\\[a-zA-Z]*cite[a-zA-Z]*(?:\[[^\[\]]*\])?){([^}]*)$/
        provider = @citation
      when 'reference'
        reg = /(?:\\[a-zA-Z]*ref[a-zA-Z]*(?:\[[^\[\]]*\])?){([^}]*)$/
        provider = @reference
      when 'environment'
        reg = /(?:\\(?:begin|end)(?:\[[^\[\]]*\])?){([^}]*)$/
        provider = @environment
      when 'command'
        reg = /\\([a-zA-Z]*)$/
        provider = @command
      when 'subFiles'
        reg = /(?:\\(?:input|include|subfile|includegraphics|addbibresource)(?:\[[^\[\]]*\])?){([^}]*)$/
        provider = @subFiles

    result = line.match(reg)
    if result
      prefix = result[1]
      if ['environment', 'command'].indexOf(type) > -1
        currentPrefix = prefix
      else
        allKeys = prefix.split(',')
        currentPrefix = allKeys[allKeys.length - 1].trim()
      suggestions = provider.provide(currentPrefix)
      if type == 'subFiles'
        if line.match(/(?:\\(?:includegraphics)(?:\[[^\[\]]*\])?){([^}]*)$/)
          suggestions = provider.provide(currentPrefix,'files-img')
        else if line.match(/(?:\\(?:addbibresource)(?:\[[^\[\]]*\])?){([^}]*)$/)
          suggestions = provider.provide(currentPrefix,'files-bib')
    return suggestions
