/** @babel */
/** @jsx etch.dom */

import etch from 'etch'
import { Disposable } from 'atom'
import Message from './message'

export default class Panel extends Disposable {
  constructor(latex) {
    super(() => this.detachStatusBar())
    this.latex = latex
    this.view = new PanelView(latex)
    this.provider = atom.views.addViewProvider(Panel,
      model => model.view.element)
    this.panel = atom.workspace.addBottomPanel({
      item: this,
      visible: this.shouldDisplay()
    })
    atom.workspace.onDidChangeActivePaneItem(() => {
      if (this.shouldDisplay()) {
        this.panel.show()
      } else {
        this.panel.hide()
      }
    })
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
}

class PanelView {
  constructor(latex) {
    this.latex = latex
    etch.initialize(this)
  }

  async destroy() {
    await etch.destroy(this)
  }

  update() {
    return etch.update(this)
  }

  render() {
    let logs = undefined
    if (this.latex.logger && this.latex.logger.log.length > 0) {
      let items = this.latex.logger.log.map(item => <Message message={item}/>)
      logs =
        <atom-panel id="atom-latex-logs" className="bottom">
          {items}
        </atom-panel>
    }
    let root = 'LaTeX root file not set.'
    if (this.latex.mainFile) {
      root = this.latex.mainFile
    }

    let buttons =
      <div id="atom-latex-controls">
        <i className="fa fa-play atom-latex-control-icon" />
        <i className="fa fa-search atom-latex-control-icon" />
        <i className="fa fa-list-ul atom-latex-control-icon" />
        <i className="fa fa-file-text-o atom-latex-control-icon" />
        <div className="atom-latex-control-separator">|</div>
        <i className="fa fa-home atom-latex-control-icon" />
        <div id="atom-latex-root-text">{root}</div>
      </div>
    return (
      <div>
        {logs}
        {buttons}
      </div>
    )
  }
}
