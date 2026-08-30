import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 250 },
    // Type-to-filter by default. Set to false (auto: false on the helper) to
    // revert to a normal form that only submits on its button / Enter.
    auto: { type: Boolean, default: true }
  }

  connect() {
    if (!this.autoValue) return
    this.boundQueue = () => this.queueSubmit()
    this.element.addEventListener("input", this.boundQueue)
  }

  disconnect() {
    clearTimeout(this.timeout)
    if (this.boundQueue) this.element.removeEventListener("input", this.boundQueue)
  }

  queueSubmit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.submit(), this.delayValue)
  }

  submit() {
    this.element.requestSubmit()
  }
}
