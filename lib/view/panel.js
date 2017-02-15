/** @babel */
/** @jsx etch.dom */

import etch from 'etch'
import { Disposable } from 'atom'

export default class Panel extends Disposable {
  constructor(latex) {
    super(() => this.detachStatusBar())
    this.latex = latex
    this.view = new PanelView()
    this.provider = atom.views.addViewProvider(Panel,
      model => model.view.element)
    this.panel = atom.workspace.addBottomPanel({
      item: this,
      visible: true
    })
  }
}

class PanelView {
  constructor() {
    etch.initialize(this)
  }

  async destroy() {
    await etch.destroy(this)
  }

  update() {
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
      return <div id="atom-latex-controls" style="display: none"/>
    }
    return (
      <div id="atom-latex-controls">
        <i className="fa fa-play atom-latex-control-icon" />
        <i className="fa fa-search atom-latex-control-icon" />
        <i className="fa fa-list-ul atom-latex-control-icon" />
        <i className="fa fa-file-text-o atom-latex-control-icon" />
        <div className="atom-latex-control-separator">|</div>
        <i className="fa fa-home atom-latex-control-icon" />
        <div id="atom-latex-root-text">LaTeX root file not set.</div>
      </div>
    )
  }
}
