/** @babel */
/** @jsx etch.dom */

import etch from 'etch'
import { Disposable } from 'atom'

export default class Status extends Disposable {
  constructor(latex) {
    super()
    this.latex = latex
  }

  attach(statusBar) {
    this.view = new StatusView()
    this.tile = statusBar.addLeftTile({
      item: this.view,
      priority: -10
    })
  }

  detach() {
    if (this.tile) {
      this.tile.destroy()
      this.tile = undefined
    }
    if (this.view) {
      this.view.destroy()
      this.view = undefined
    }
  }
}

class StatusView {
  constructor() {
    etch.initialize(this)
    this.addTooltip()
    atom.workspace.onDidChangeActivePaneItem(() => etch.update(this))
  }

  async destroy() {
    if (this.tooltip) {
      this.tooltip.dispose()
    }
    await etch.destroy(this)
  }

  addTooltip() {
    if (this.tooltip) {
      this.tooltip.dispose()
    }
    this.tooltip = atom.tooltips.add(this.element, { title: 'Atom-LaTeX Panel' })
  }

  update() {
    this.addTooltip()
    return etch.update(this)
  }

  shouldDisplay() {
    let editor = atom.workspace.getActiveTextEditor()
    if (!editor) {
      return false
    }
    let grammar = editor.getGrammar()
    if (!grammar) {
      return false
    }
    if ((grammar.packageName === 'atom-latex') ||
      (grammar.scopeName.indexOf('text.tex.latex') > -1)) {
      return true
    }
    return false
  }

  render() {
    if (!this.shouldDisplay()) {
      return <div id="atom-latex-status-bar" style="display: none"/>
    }
    return (
      <div id="atom-latex-status-bar" style="display: inline-block">
        <a href="#" className="inline-block" style="text-decoration:none">
          <div className="icon icon-file inline-block"/>
          LaTeX
        </a>
      </div>
    )
  }
}
  // constructor: ->
  //   @element = document.createElement 'div'
  //   @element.id = 'status-bar-atom-latex'
  //   @element.classList.add 'inline-block'
  //   @link = document.createElement 'a'
  //   @link.classList.add 'inline-block'
  //   @link.text = 'LaTeX'
  //   @link.href = '#'
  //   @element.appendChild(@link)
  //
  //   @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
  //     @subscribeToActiveItem()
  //   @subscribeToActiveItem()
  //
  // destroy: ->
  //   @activeItemSubscription?.dispose()
  //
  // shouldDisplay: ->
  //   grammar = atom.workspace.getActiveTextEditor()?.getGrammar()
  //   if (grammar?.packageName is 'atom-latex') or
  //       (grammar?.scopeName.indexOf('text.tex.latex') > -1)
  //     return true
  //   return false
  //
  // subscribeToActiveItem: ->
  //   if @shouldDisplay()
  //     document.getElementById('status-bar-atom-latex')?.style.display =
  //       'inline-block'
  //   else
  //     document.getElementById('status-bar-atom-latex')?.style.display = 'none'
  //
  // render: ->
  //   if !@shouldDisplay()
  //     return <div />
