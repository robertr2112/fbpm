// Bootstrap 5 code
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    this.showModal()
  }

  showModal() {
    if (this.modalTarget) {
      const modal = new bootstrap.Modal(this.modalTarget)
      modal.show()
    }
  }
}