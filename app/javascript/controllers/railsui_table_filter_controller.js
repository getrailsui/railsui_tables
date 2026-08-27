import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { delay: { type: Number, default: 250 } }

  connect() {
    this.submit = this.submit.bind(this)
  }

  queueSubmit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(this.submit, this.delayValue)
  }

  submit() {
    this.element.requestSubmit()
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
