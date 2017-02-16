/** @babel */
/** @jsx etch.dom */

import etch from 'etch'
import { Disposable } from 'atom'

export default class Message {
  constructor(properties = {}) {
    this.properties = properties
    etch.initialize(this)
  }

  async destroy() {
    await etch.destroy(this)
  }

  update(properties) {
    this.properties = properties
    return etch.update(this)
  }

  getIconClass() {
    let iconName = undefined
    switch (this.properties.message.type) {
      case 'error':
        iconName = 'fa-times-circle'
        break;
      case 'warning':
        iconName = 'fa-exclamation-circle'
        break;
      case 'typesetting':
        iconName = 'fa-question-circle'
        break;
      default:
        iconName = 'fa-info-circle'
    }
    return `fa ${iconName} atom-latex-log-icon`
  }

  render() {
    return (
      <div className="atom-latex-log-message">
        <i className={this.getIconClass()}/>
        {this.properties.message.text}
      </div>
    )
  }
}
