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
    this.showLog = true
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
    if (this.latex.logger && this.latex.logger.log.length > 0 && this.showLog) {
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
        <ButtonView icon="play" tooltip="Build LaTeX" click={()=>this.latex.builder.build()}/>
        <ButtonView icon="search" tooltip="Preview PDF" click={()=>this.latex.viewer.openViewer()}/>
        <ButtonView icon="list-ul" tooltip={this.showLog?"Hide build log":"Show build log"} click={()=>this.toggleLog()} dim={!this.showLog}/>
        <ButtonView icon="file-text-o" tooltip="Show raw log" click={()=>this.latex.logger.showLog()}/>
        <div className="atom-latex-control-separator">|</div>
        <ButtonView icon="home" tooltip="Set LaTeX root" click={()=>this.latex.manager.refindMain()}/>
        <div id="atom-latex-root-text">{root}</div>
      </div>
    return (
      <div>
        {logs}
        {buttons}
      </div>
    )
  }

  toggleLog() {
    this.showLog = !this.showLog
    this.update()
  }
}

class ButtonView {
  constructor(properties = {}) {
    this.properties = properties
    etch.initialize(this)
    this.addTooltip()
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
    this.tooltip = atom.tooltips.add(this.element, { title: this.properties.tooltip })
  }

  update(properties) {
    this.properties = properties
    this.addTooltip()
    return etch.update(this)
  }

  render() {
    return (
      <i className={`fa fa-${this.properties.icon} atom-latex-control-icon ${this.properties.dim?' atom-latex-dimmed':''}`} onclick={this.properties.click}/>
    )
  }


}
