import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("shown.bs.tab", this.load.bind(this))

    // Load the initially active tab
    const activeTab = this.element.querySelector(".nav-link.active")
    if (activeTab) {
      this.load({ target: activeTab })
    }
  }

  load(event) {
    const button = event.target
    const url = button.dataset.url
    const frameId = button.dataset.turboFrame

    if (!url || !frameId) return

    const frame = document.getElementById(frameId)

    // Only load once
    if (frame.dataset.loaded) return

    frame.dataset.loaded = true
    frame.src = url
  }
}
