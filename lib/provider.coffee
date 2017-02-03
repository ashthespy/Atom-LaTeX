{ Disposable } = require 'atom'
Citation = require './autocomplete/citation'
Reference = require './autocomplete/reference'
Environment = require './autocomplete/environment'
Command = require './autocomplete/command'

module.exports =
class Provider extends Disposable
  constructor: (latex) ->
    @latex = latex
    @citation = new Citation(@latex)
    @reference = new Reference(@latex)
    @environment = new Environment(@latex)
    @command = new Command(@latex)

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

        for command in ['citation', 'reference', 'environment', 'command']
          suggestions = atom_latex.provider.completeCommand(line, command)
          resolve(suggestions) if suggestions?

        resolve([])

    onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->
      if suggestion.chainComplete
        setTimeout(( -> atom.packages.getActivePackage('autocomplete-plus')\
          .mainModule.autocompleteManager.findSuggestions()), 100)
      if suggestion.latexType is 'environment'
        if suggestion.additionalInsert?
          row = triggerPosition.row - 1
          col = editor.buffer.lines[row].length
          editor.buffer.insert(
            {row: row, column: col}, suggestion.additionalInsert)

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

    result = line.match(reg)
    if result
      prefix = result[1]
      if ['environment', 'command'].indexOf(type) > -1
        currentPrefix = prefix
      else
        allKeys = prefix.split(',')
        currentPrefix = allKeys[allKeys.length - 1].trim()
      suggestions = provider.provide(currentPrefix)
    return suggestions
