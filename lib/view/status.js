/** @babel */
/** @jsx etch.dom */

import etch from 'etch'
import { Disposable } from 'atom'

export default class Status extends Disposable {
  constructor() {
    super()
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
    this.status = 'ready'
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
    let handleClick = () => {
      if (atom_latex.latex)
        atom_latex.latex.panel.togglePanel()
    }
    return (
      <div id="atom-latex-status-bar" style="display: inline-block" onclick={handleClick}>
        <i id="atom-latex-status-bar-icon" className={`fa ${this.getIcon()}`}/>
        <span style="margin-left: 5px">LaTeX</span>
      </div>
    )
  }

  getIcon() {
    switch (this.status) {
      case 'error':
        return 'fa-times-circle'
      case 'warning':
        return 'fa-exclamation-circle'
      case 'typesetting':
        return 'fa-question-circle'
      case 'good':
        return 'fa-check-circle'
      case 'building':
        return 'fa-cog fa-spin'
      case 'skipped':
        return 'fa-question-circle atom-latex-latexmk-skipped'
      default:
        return 'fa-file-text-o'
    }
  }
}
