// Bootstrap 5 code
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  // Determines if the modal should auto-show on connect.
  shouldAutoShow() {
    // Explicit opt-in via data-modal-auto-show="true" or data-auto-show="true"
    const ds = this.element.dataset || {}
    if (ds.modalAutoShow === 'true' || ds.autoShow === 'true') return true

    // If the modal markup itself already has the 'show' class, respect that too
    if (this.modalTarget && this.modalTarget.classList.contains('show')) return true

    return false
  }

  connect() {
    // If a global bootstrap is already present, use it synchronously.
    if (window.bootstrap) {
      this._bootstrap = window.bootstrap
      if (this.shouldAutoShow()) this.showModal()
      return
    }

    // Otherwise dynamically import the module (works with importmap pin 'bootstrap')
    import("bootstrap").then((mod) => {
      // Some bundlers export the module as the default, others as named exports.
      // Normalize to an object that has Modal on it.
      this._bootstrap = mod && (mod.Modal ? mod : (mod.default || mod))
      if (this.shouldAutoShow()) this.showModal()
    }).catch((e) => {
      console.error('[modal] failed to load bootstrap module', e)
    })
  }

  showModal() {
    if (!this.modalTarget) return

    try {
      const bootstrapLib = this._bootstrap || window.bootstrap
      if (!bootstrapLib || !bootstrapLib.Modal) {
        console.warn('[modal] bootstrap Modal not available')
        return
      }

      const modal = new bootstrapLib.Modal(this.modalTarget)
      modal.show()
    } catch (e) {
      console.error('[modal] failed to show modal', e)
    }
  }
}