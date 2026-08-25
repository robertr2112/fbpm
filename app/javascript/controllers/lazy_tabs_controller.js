import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.boundLoad = this.load.bind(this)
    this.element.querySelectorAll(".nav-link").forEach((button) => {
      button.addEventListener("shown.bs.tab", this.boundLoad)
    })

    const activeTab = this.element.querySelector(".nav-link.active")
    if (activeTab) {
      this.scheduleLoad(activeTab)
    }
  }

  disconnect() {
    if (!this.boundLoad) return

    this.element.querySelectorAll(".nav-link").forEach((button) => {
      button.removeEventListener("shown.bs.tab", this.boundLoad)
    })
  }

  scheduleLoad(button) {
    requestAnimationFrame(() => this.load({ target: button }))
  }

  load(event) {
    const button = event?.target?.closest?.(".nav-link") || event?.currentTarget || this.element.querySelector(".nav-link.active")
    if (!button) return

    const url = button.dataset?.url
    if (!url) return

    const frameId = button.dataset?.turboFrame
    const targetSelector = button.dataset?.bsTarget

    let frame = frameId ? document.getElementById(frameId) : null
    if (!frame && targetSelector) {
      const pane = document.querySelector(targetSelector)
      frame = pane?.querySelector("turbo-frame") || null
    }

    if (!frame) {
      // Bootstrap can fire the tab event before the pane is mounted, especially when the
      // controller reconnects or the user clicks quickly. Retry on the next animation frame.
      this.scheduleLoad(button)
      return
    }

    if (frame.dataset.loaded) return

    frame.dataset.loaded = true
    frame.setAttribute("src", url)
  }
}
