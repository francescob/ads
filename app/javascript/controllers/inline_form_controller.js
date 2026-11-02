import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "display"]

  toggle() {
    this.formTarget.classList.toggle("hidden")
    this.displayTarget.classList.toggle("hidden")
  }
}