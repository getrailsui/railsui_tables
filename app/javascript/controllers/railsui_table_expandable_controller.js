import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    const button = event.currentTarget
    const detail = document.getElementById(button.dataset.detailId)
    if (!detail) return

    event.preventDefault()
    const expanded = button.getAttribute("aria-expanded") === "true"
    button.setAttribute("aria-expanded", String(!expanded))
    detail.hidden = expanded

    if (!expanded) {
      const frame = detail.querySelector("turbo-frame[data-src]")
      if (frame && !frame.getAttribute("src")) frame.setAttribute("src", frame.dataset.src)
    }
  }
}
