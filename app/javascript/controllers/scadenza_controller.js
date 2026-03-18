import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row"]

  connect() {
    // Controller connected
  }

  markComplete(event) {
    const row = event.currentTarget.closest("[data-scadenza-target='row']")
    if (row) {
      row.classList.add("opacity-50")
    }
  }
}
